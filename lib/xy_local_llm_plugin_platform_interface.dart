import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xy_local_llm_plugin_method_channel.dart';

abstract class XyLocalLlmPluginPlatform extends PlatformInterface {
  /// Constructs a XyLocalLlmPluginPlatform.
  XyLocalLlmPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static XyLocalLlmPluginPlatform _instance = MethodChannelXyLocalLlmPlugin();

  /// The default instance of [XyLocalLlmPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelXyLocalLlmPlugin].
  static XyLocalLlmPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XyLocalLlmPluginPlatform] when
  /// they register themselves.
  static set instance(XyLocalLlmPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isRunning() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getModelInfo() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getOutput() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isModelLoaded() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> generate(String prompt) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> loadModel(String model) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setTemperature(double temperature) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setMaxTokens(int maxTokens) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<double> getTemperature() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int> getMaxTokens() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
