import Flutter
import UIKit

import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import Metal
import Tokenizers

public class XyLocalLlmPlugin: NSObject, FlutterPlugin {
    var evaluator: LLMEvaluator = LLMEvaluator()
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "xy_local_llm_plugin", binaryMessenger: registrar.messenger())
        let instance = XyLocalLlmPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setTemperature":
            evaluator.generateParameters = GenerateParameters(temperature: Float(call.arguments as! Double)) 
        case "setMaxTokens":
            evaluator.maxTokens = call.arguments as! Int
        case "getTemperature":
            result(evaluator.generateParameters.temperature)
        case "getMaxTokens":
            result(evaluator.maxTokens)
        case "isRunning":
            result(evaluator.running)
        case "getModelInfo":
            result(evaluator.modelInfo)
        case "getOutput":
            result(evaluator.output)
        case "isModelLoaded":
            if case .loaded = evaluator.loadState {
                result(true)
            } else {
                result(false)
            }
        case "generate":
            Task {
                do {
                    try await evaluator.generate(prompt: call.arguments as! String)
                } catch {
                    print("Error: \(error)")
                }
            }
        case "loadModel":
            evaluator.loadState = .idle
            Task {
                do {
                    try await evaluator.load(model: call.arguments as! String)
                } catch {
                    print("Error: \(error)")
                }
            }    
            result("Loading model...")    
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class LLMEvaluator {

    var running: Bool = false
    var output = ""
    var modelInfo = ""
    var stat = ""
    /// This controls which model loads. `phi3_5_4bit` is one of the smaller ones, so this will fit on
    /// more devices.
    var modelConfiguration = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit",
        defaultPrompt: "What is the gravity on Mars and the moon Phobos?",
        extraEOSTokens: ["<|end|>"]
    )

    /// parameters controlling the output
    var generateParameters = GenerateParameters(temperature: 0.6)
    var maxTokens = 1024


    /// update the display every N tokens -- 4 looks like it updates continuously
    /// and is low overhead.  observed ~15% reduction in tokens/s when updating
    /// on every token
    var displayEveryNTokens = 4

    enum LoadState {
        case idle
        case loaded(ModelContainer)
    }

    var loadState = LoadState.idle

    /// load and return the model -- can be called multiple times, subsequent calls will
    /// just return the loaded model
    func load(model: String? = nil) async throws -> ModelContainer {
        if let model = model {
            modelConfiguration = ModelConfiguration(
                id: model,
                defaultPrompt: "What is the gravity on Mars and the moon Phobos?",
                extraEOSTokens: ["<|end|>"]
            )
        }
        switch loadState {
        case .idle:
            // limit the buffer cache
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            let modelContainer = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfiguration
            ) {
                [modelConfiguration] progress in
                Task { 
                    self.modelInfo =
                        "Downloading \(modelConfiguration.name): \(Int(progress.fractionCompleted * 100))%"
                    print(self.modelInfo)
                }
            }
            let numParams = await modelContainer.perform { context in
                context.model.numParameters()
            }

            self.modelInfo =
                "Loaded \(modelConfiguration.name).  Weights: \(numParams / (1024*1024))M"
            loadState = .loaded(modelContainer)
            return modelContainer

        case .loaded(let modelContainer):
            return modelContainer
        }
    }

    func generate(prompt: String) async {
        guard !running else { return }

        running = true
        self.output = ""

        do {
            let modelContainer = try await load()

            // each time you generate you will get something new
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))

            let result = try await modelContainer.perform { context in
                let input = try await context.processor.prepare(input: .init(prompt: prompt))
                return try MLXLMCommon.generate(
                    input: input, parameters: generateParameters, context: context
                ) { tokens in
                    // update the output -- this will make the view show the text as it generates
                    if tokens.count % displayEveryNTokens == 0 {
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in
                            self.output = text
                            print(self.output)
                        }
                    }

                    if tokens.count >= maxTokens {
                        return .stop
                    } else {
                        return .more
                    }
                }
            }

            // update the text if needed, e.g. we haven't displayed because of displayEveryNTokens
            if result.output != self.output {
                self.output = result.output
            }
            self.stat = " Tokens/second: \(String(format: "%.3f", result.tokensPerSecond))"

        } catch {
            output = "Failed: \(error)"
        }

        running = false
    }
}
