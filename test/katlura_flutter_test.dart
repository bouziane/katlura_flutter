import 'package:flutter_test/flutter_test.dart';
import 'package:katlura_flutter/katlura_flutter.dart';
import 'package:katlura_flutter/katlura_flutter_platform_interface.dart';
import 'package:katlura_flutter/katlura_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockKatluraFlutterPlatform
    with MockPlatformInterfaceMixin
    implements KatluraFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final KatluraFlutterPlatform initialPlatform = KatluraFlutterPlatform.instance;

  test('$MethodChannelKatluraFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelKatluraFlutter>());
  });

  test('getPlatformVersion', () async {
    KatluraFlutter katluraFlutterPlugin = KatluraFlutter();
    MockKatluraFlutterPlatform fakePlatform = MockKatluraFlutterPlatform();
    KatluraFlutterPlatform.instance = fakePlatform;

    expect(await katluraFlutterPlugin.getPlatformVersion(), '42');
  });
}
