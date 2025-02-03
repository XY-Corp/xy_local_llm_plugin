import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:xy_local_llm_plugin/xy_local_llm_plugin.dart';
import 'package:xy_local_llm_plugin/xy_conversation.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _modelInfo = 'Unknown';
  final conversation = Conversation();
  final _xyLocalLlmPlugin = XyLocalLlmPlugin();
  String _model = "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit";
  final _models = [
    "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit",
    "mlx-community/DeepSeek-R1-Distill-Qwen-7B-3bit"
  ];
  bool _loaded = false;
  bool _isLoading = true;
  double _temperature = 0.5;
  int _maxTokens = 1000;

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _maxTokensController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();
    startFetching();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      setState(() {
        _isLoading = true;
      });
      _xyLocalLlmPlugin.loadModel(_model);
      _modelInfo = await _xyLocalLlmPlugin.getModelInfo() ?? 'No model info';
      _temperature = await _xyLocalLlmPlugin.getTemperature();
      _maxTokens = await _xyLocalLlmPlugin.getMaxTokens();
      _temperatureController.text = _temperature.toString();
      _maxTokensController.text = _maxTokens.toString();
    } on PlatformException {
      _modelInfo = 'Error loading model';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    await updateOutput();
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startFetching() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      await updateOutput();
    });
  }

  updateOutput() async {
    final output = await _xyLocalLlmPlugin.getModelInfo();
    final loaded = await _xyLocalLlmPlugin.isModelLoaded();
    final isModelLoaded = await _xyLocalLlmPlugin.isModelLoaded();
    setState(() {
      _modelInfo = output ?? 'No Info';
      _loaded = loaded;
      _isLoading = !isModelLoaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset(
          'assets/logo.png',
          height: 42,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                useSafeArea: true,
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Model Info: $_modelInfo',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Model Loaded: ${_loaded ? "Yes" : "No"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _model,
                          items: _models.map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              setState(() {
                                _model = newValue;
                                _isLoading = true;
                              });
                              await _xyLocalLlmPlugin.loadModel(newValue);
                              await updateOutput();
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _temperatureController,
                          decoration:
                              const InputDecoration(labelText: 'Temperature'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _xyLocalLlmPlugin
                                .setTemperature(double.parse(value));
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _maxTokensController,
                          decoration:
                              const InputDecoration(labelText: 'Max Tokens'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _xyLocalLlmPlugin.setMaxTokens(int.parse(value));
                          },
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _loaded ? '$_modelInfo' : '$_modelInfo',
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _loaded ? '$_modelInfo' : '$_modelInfo',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  color: Colors.blueGrey,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversation.messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: message.isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.thought.isNotEmpty)
                                Text(
                                  message.thought,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isUser
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_loaded)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (text) async {
                              if (text.isNotEmpty) {
                                final message = text;
                                _textEditingController.clear();
                                setState(() {});
                                await conversation.sendMessage(message);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (_textEditingController.text.isNotEmpty) {
                              final message = _textEditingController.text;
                              _textEditingController.clear();
                              setState(() {});
                              await conversation.sendMessage(message);
                              setState(() {});
                            }
                          },
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
