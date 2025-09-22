import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/flutter_freedome_player.dart';
import 'package:flutter_freedome_player/src/flutter_freedome_player_platform_interface.dart';
import 'package:flutter_freedome_player/src/flutter_freedome_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFreedomePlayerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterFreedomePlayerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> initializeRenderer() => Future.value(true);

  @override
  Future<bool> loadModel(String modelPath) => Future.value(true);

  @override
  Future<bool> startARSession() => Future.value(true);

  @override
  Future<bool> stopARSession() => Future.value(true);

  @override
  Future<bool> connectToDome(String host, int port) => Future.value(true);

  @override
  Future<bool> sendOSCMessage(String address, List<dynamic> args) =>
      Future.value(true);
}

void main() {
  final FreeDomePlayer freedomePlayerPlatform = FreeDomePlayer();
  MockFlutterFreedomePlayerPlatform fakePlatform =
      MockFlutterFreedomePlayerPlatform();

  setUp(() {
    FlutterFreedomePlayerPlatform.instance = fakePlatform;
  });

  test('getPlatformVersion', () async {
    expect(await freedomePlayerPlatform.getPlatformVersion(), '42');
  });

  test('initializeRenderer', () async {
    expect(await freedomePlayerPlatform.initializeRenderer(), true);
  });

  test('isFormatSupported', () {
    expect(freedomePlayerPlatform.isFormatSupported('test.dae'), true);
    expect(freedomePlayerPlatform.isFormatSupported('test.comics'), true);
    expect(freedomePlayerPlatform.isFormatSupported('test.txt'), false);
  });

  test('getSupportedFormats', () {
    final formats = freedomePlayerPlatform.getSupportedFormats();
    expect(formats, contains('comics'));
    expect(formats, contains('collada'));
    expect(formats, contains('boranko'));
  });

  test('createMediaContent', () {
    final content = FreeDomePlayer.createMediaContent(
      filePath: 'test.dae',
      name: 'Test Model',
    );

    expect(content.name, 'Test Model');
    expect(content.format, MediaFormat.collada);
    expect(content.filePath, 'test.dae');
  });
}
