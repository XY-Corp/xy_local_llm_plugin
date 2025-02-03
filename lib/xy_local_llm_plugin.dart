import 'xy_local_llm_plugin_platform_interface.dart';

class XyLocalLlmPlugin {
  Future<String?> getModelInfo() {
    return XyLocalLlmPluginPlatform.instance.getModelInfo();
  }

  Future<String?> getOutput() {
    return XyLocalLlmPluginPlatform.instance.getOutput();
  }

  Future<bool> isModelLoaded() {
    return XyLocalLlmPluginPlatform.instance.isModelLoaded();
  }

  Future<void> generate(String prompt) {
    return XyLocalLlmPluginPlatform.instance.generate(prompt);
  }

  Future<void> loadModel(String model) {
    return XyLocalLlmPluginPlatform.instance.loadModel(model);
  }

  Future<bool> isRunning() {
    return XyLocalLlmPluginPlatform.instance.isRunning();
  }

  Future<void> setTemperature(double temperature) {
    return XyLocalLlmPluginPlatform.instance.setTemperature(temperature);
  }

  Future<void> setMaxTokens(int maxTokens) {
    return XyLocalLlmPluginPlatform.instance.setMaxTokens(maxTokens);
  }

  Future<double> getTemperature() {
    return XyLocalLlmPluginPlatform.instance.getTemperature();
  }

  Future<int> getMaxTokens() {
    return XyLocalLlmPluginPlatform.instance.getMaxTokens();
  }
}
