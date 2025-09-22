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
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
