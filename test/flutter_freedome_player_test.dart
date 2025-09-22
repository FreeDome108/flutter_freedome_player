import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/flutter_freedome_player.dart';
import 'package:flutter_freedome_player/flutter_freedome_player_platform_interface.dart';
import 'package:flutter_freedome_player/flutter_freedome_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFreedomePlayerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterFreedomePlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterFreedomePlayerPlatform initialPlatform = FlutterFreedomePlayerPlatform.instance;

  test('$MethodChannelFlutterFreedomePlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFreedomePlayer>());
  });

  test('getPlatformVersion', () async {
    FlutterFreedomePlayer flutterFreedomePlayerPlugin = FlutterFreedomePlayer();
    MockFlutterFreedomePlayerPlatform fakePlatform = MockFlutterFreedomePlayerPlatform();
    FlutterFreedomePlayerPlatform.instance = fakePlatform;

    expect(await flutterFreedomePlayerPlugin.getPlatformVersion(), '42');
  });
}
