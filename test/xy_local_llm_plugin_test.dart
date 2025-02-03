import 'package:flutter_test/flutter_test.dart';
import 'package:xy_local_llm_plugin/xy_local_llm_plugin.dart';
import 'package:xy_local_llm_plugin/xy_local_llm_plugin_platform_interface.dart';
import 'package:xy_local_llm_plugin/xy_local_llm_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockXyLocalLlmPluginPlatform
    with MockPlatformInterfaceMixin
    implements XyLocalLlmPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final XyLocalLlmPluginPlatform initialPlatform = XyLocalLlmPluginPlatform.instance;

  test('$MethodChannelXyLocalLlmPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelXyLocalLlmPlugin>());
  });

  test('getPlatformVersion', () async {
    XyLocalLlmPlugin xyLocalLlmPlugin = XyLocalLlmPlugin();
    MockXyLocalLlmPluginPlatform fakePlatform = MockXyLocalLlmPluginPlatform();
    XyLocalLlmPluginPlatform.instance = fakePlatform;

    expect(await xyLocalLlmPlugin.getPlatformVersion(), '42');
  });
}
