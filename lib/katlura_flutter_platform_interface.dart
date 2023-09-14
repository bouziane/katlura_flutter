import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'katlura_flutter_method_channel.dart';

abstract class KatluraFlutterPlatform extends PlatformInterface {
  /// Constructs a KatluraFlutterPlatform.
  KatluraFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static KatluraFlutterPlatform _instance = MethodChannelKatluraFlutter();

  /// The default instance of [KatluraFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelKatluraFlutter].
  static KatluraFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KatluraFlutterPlatform] when
  /// they register themselves.
  static set instance(KatluraFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
