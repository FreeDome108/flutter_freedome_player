import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_freedome_player_method_channel.dart';

abstract class FlutterFreedomePlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterFreedomePlayerPlatform.
  FlutterFreedomePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFreedomePlayerPlatform _instance = MethodChannelFlutterFreedomePlayer();

  /// The default instance of [FlutterFreedomePlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFreedomePlayer].
  static FlutterFreedomePlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFreedomePlayerPlatform] when
  /// they register themselves.
  static set instance(FlutterFreedomePlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
