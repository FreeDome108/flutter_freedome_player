import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_freedome_player_platform_interface.dart';

/// An implementation of [FlutterFreedomePlayerPlatform] that uses method channels.
class MethodChannelFlutterFreedomePlayer extends FlutterFreedomePlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_freedome_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> initializeRenderer() async {
    try {
      final result =
          await methodChannel.invokeMethod<bool>('initializeRenderer');
      return result ?? false;
    } catch (e) {
      debugPrint('Error initializing renderer: $e');
      return false;
    }
  }

  @override
  Future<bool> loadModel(String modelPath) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('loadModel', {
        'modelPath': modelPath,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error loading model: $e');
      return false;
    }
  }

  @override
  Future<bool> startARSession() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('startARSession');
      return result ?? false;
    } catch (e) {
      debugPrint('Error starting AR session: $e');
      return false;
    }
  }

  @override
  Future<bool> stopARSession() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('stopARSession');
      return result ?? false;
    } catch (e) {
      debugPrint('Error stopping AR session: $e');
      return false;
    }
  }

  @override
  Future<bool> connectToDome(String host, int port) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('connectToDome', {
        'host': host,
        'port': port,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error connecting to dome: $e');
      return false;
    }
  }

  @override
  Future<bool> sendOSCMessage(String address, List<dynamic> args) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('sendOSCMessage', {
        'address': address,
        'args': args,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error sending OSC message: $e');
      return false;
    }
  }
}
