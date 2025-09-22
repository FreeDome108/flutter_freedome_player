import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_freedome_player_method_channel.dart';

abstract class FlutterFreedomePlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterFreedomePlayerPlatform.
  FlutterFreedomePlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFreedomePlayerPlatform _instance =
      MethodChannelFlutterFreedomePlayer();

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

  /// Get platform version
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

  /// Initialize native 3D renderer
  Future<bool> initializeRenderer() {
    throw UnimplementedError('initializeRenderer() has not been implemented.');
  }

  /// Load 3D model on native side
  Future<bool> loadModel(String modelPath) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Start AR session
  Future<bool> startARSession() {
    throw UnimplementedError('startARSession() has not been implemented.');
  }

  /// Stop AR session
  Future<bool> stopARSession() {
    throw UnimplementedError('stopARSession() has not been implemented.');
  }

  /// Connect to dome projection system
  Future<bool> connectToDome(String host, int port) {
    throw UnimplementedError('connectToDome() has not been implemented.');
  }

  /// Send OSC message to dome
  Future<bool> sendOSCMessage(String address, List<dynamic> args) {
    throw UnimplementedError('sendOSCMessage() has not been implemented.');
  }
}
