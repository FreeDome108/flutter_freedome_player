import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';
import 'package:flutter_freedome_player/src/freedome_player_controller.dart';
import 'package:flutter_freedome_player/src/freedome_player.dart';

void main() {
  group('Simplified Widget Tests (No WebView)', () {
    testWidgets('should create MediaContent correctly', (tester) async {
      final content = FreeDomePlayer.createMediaContent(
        filePath: 'assets/test.dae',
        name: 'Test Model',
      );

      expect(content.name, equals('Test Model'));
      expect(content.format, equals(MediaFormat.collada));
      expect(content.filePath, equals('assets/test.dae'));
    });

    testWidgets('should create PlayerConfig correctly', (tester) async {
      const config = PlayerConfig(enableAR: true, backgroundColor: 0xFF123456);

      expect(config.enableAR, isTrue);
      expect(config.backgroundColor, equals(0xFF123456));
    });

    testWidgets('should create FreeDomePlayerController correctly', (
      tester,
    ) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      expect(controller, isA<FreeDomePlayerController>());
      expect(controller.hasContent, isFalse);
      expect(controller.isPlaying, isFalse);

      controller.dispose();
    });

    testWidgets('should load content in controller', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      expect(controller.hasContent, isTrue);
      expect(controller.currentContent, equals(content));

      controller.dispose();
    });

    testWidgets('should handle playback states', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      // Test play
      await controller.play();
      expect(controller.isPlaying, isTrue);

      // Test pause
      controller.pause();
      expect(controller.isPlaying, isFalse);

      // Test stop
      controller.stop();
      expect(controller.isPlaying, isFalse);

      controller.dispose();
    });

    testWidgets('should detect formats correctly', (tester) async {
      final player = FreeDomePlayer();

      expect(player.isFormatSupported('test.comics'), isTrue);
      expect(player.isFormatSupported('test.dae'), isTrue);
      expect(player.isFormatSupported('test.boranko'), isTrue);
      expect(player.isFormatSupported('test.txt'), isFalse);
    });

    testWidgets('should provide supported formats list', (tester) async {
      final player = FreeDomePlayer();
      final formats = player.getSupportedFormats();

      expect(formats, hasLength(6));
      expect(formats, contains('comics'));
      expect(formats, contains('collada'));
      expect(formats, contains('boranko'));
    });

    testWidgets('should create recommended configs', (tester) async {
      final player = FreeDomePlayer();

      final comicsConfig = player.getRecommendedConfig(MediaFormat.comics);
      expect(comicsConfig.enableAR, isFalse);
      expect(comicsConfig.autoRotate, isFalse);

      final modelConfig = player.getRecommendedConfig(MediaFormat.collada);
      expect(modelConfig.enableAR, isTrue);
      expect(modelConfig.autoRotate, isTrue);

      final borankoConfig = player.getRecommendedConfig(MediaFormat.boranko);
      expect(borankoConfig.enableDomeProjection, isTrue);
      expect(borankoConfig.enableVR, isTrue);
    });

    testWidgets('should handle controller state changes', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      int notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);
      expect(notificationCount, equals(1));

      const newConfig = PlayerConfig(enableAR: false);
      controller.updateConfig(newConfig);
      expect(notificationCount, equals(2));

      controller.clearContent();
      expect(notificationCount, equals(3));

      controller.dispose();
    });

    testWidgets('should switch playback modes correctly', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      // Test mode switching
      controller.switchPlaybackMode(PlaybackMode.ar);
      expect(controller.currentContent!.playbackMode, equals(PlaybackMode.ar));

      controller.switchPlaybackMode(PlaybackMode.dome);
      expect(
        controller.currentContent!.playbackMode,
        equals(PlaybackMode.dome),
      );

      controller.dispose();
    });

    testWidgets('should get available playback modes', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      // Test for comics (limited modes)
      const comicsContent = MediaContent(
        id: 'comics',
        name: 'Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      controller.loadMediaContent(comicsContent);
      final comicsModes = controller.getAvailablePlaybackModes();
      expect(comicsModes, equals([PlaybackMode.screen]));

      // Test for 3D model (more modes)
      const modelContent = MediaContent(
        id: 'model',
        name: 'Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(modelContent);
      final modelModes = controller.getAvailablePlaybackModes();
      expect(modelModes.length, greaterThan(1));
      expect(modelModes, contains(PlaybackMode.screen));
      expect(modelModes, contains(PlaybackMode.ar));

      controller.dispose();
    });

    testWidgets('should handle format auto-configuration', (tester) async {
      final player = FreeDomePlayer();
      final controller = player.createController();

      // Test comics auto-config
      const comicsContent = MediaContent(
        id: 'comics',
        name: 'Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      controller.loadMediaContent(comicsContent);
      expect(controller.config.enableAR, isFalse);
      expect(controller.config.autoRotate, isFalse);

      // Test 3D model auto-config
      const modelContent = MediaContent(
        id: 'model',
        name: 'Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      controller.loadMediaContent(modelContent);
      expect(controller.config.enableAR, isTrue);
      expect(controller.config.autoRotate, isTrue);

      controller.dispose();
    });
  });
}
