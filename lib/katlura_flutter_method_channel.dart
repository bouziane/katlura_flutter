import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'katlura_flutter_platform_interface.dart';

/// An implementation of [KatluraFlutterPlatform] that uses method channels.
class MethodChannelKatluraFlutter extends KatluraFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('katlura_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
