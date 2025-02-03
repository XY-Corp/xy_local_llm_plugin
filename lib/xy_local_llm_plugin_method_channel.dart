import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xy_local_llm_plugin_platform_interface.dart';

/// An implementation of [XyLocalLlmPluginPlatform] that uses method channels.
class MethodChannelXyLocalLlmPlugin extends XyLocalLlmPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xy_local_llm_plugin');

  @override
  Future<String?> getModelInfo() async {
    final version = await methodChannel.invokeMethod<String>('getModelInfo');
    return version;
  }

  @override
  Future<String?> getOutput() async {
    final version = await methodChannel.invokeMethod<String>('getOutput');
    return version;
  }

  @override
  Future<bool> isModelLoaded() async {
    final loaded = await methodChannel.invokeMethod<bool>('isModelLoaded');
    return loaded ?? false;
  }

  @override
  Future<void> generate(String prompt) async {
    await methodChannel.invokeMethod<void>('generate', prompt);
  }

  @override
  Future<void> loadModel(String model) async {
    await methodChannel.invokeMethod<void>('loadModel', model);
  }

  @override
  Future<bool> isRunning() async {
    final running = await methodChannel.invokeMethod<bool>('isRunning');
    return running ?? false;
  }

  @override
  Future<void> setTemperature(double temperature) async {
    await methodChannel.invokeMethod<void>('setTemperature', temperature);
  }

  @override
  Future<void> setMaxTokens(int maxTokens) async {
    await methodChannel.invokeMethod<void>('setMaxTokens', maxTokens);
  }

  @override
  Future<double> getTemperature() async {
    final temperature =
        await methodChannel.invokeMethod<double>('getTemperature');
    return temperature ?? 0.5;
  }

  @override
  Future<int> getMaxTokens() async {
    final maxTokens = await methodChannel.invokeMethod<int>('getMaxTokens');
    return maxTokens ?? 1000;
  }
}
