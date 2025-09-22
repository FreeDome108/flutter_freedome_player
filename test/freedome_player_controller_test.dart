import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/freedome_player_controller.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';

void main() {
  group('FreeDomePlayerController', () {
    late FreeDomePlayerController controller;

    setUp(() {
      controller = FreeDomePlayerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with default values', () {
      expect(controller.currentContent, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isPlaying, isFalse);
      expect(controller.error, isNull);
      expect(controller.hasContent, isFalse);
      expect(controller.config, isA<PlayerConfig>());
    });

    test('should update configuration', () {
      const newConfig = PlayerConfig(
        enableAR: false,
        enableVR: true,
        backgroundColor: 0xFF123456,
      );

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.updateConfig(newConfig);

      expect(controller.config, equals(newConfig));
      expect(notified, isTrue);
    });

    test('should load media content', () {
      const content = MediaContent(
        id: 'test_id',
        name: 'Test Content',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.loadMediaContent(content);

      expect(controller.currentContent, equals(content));
      expect(controller.hasContent, isTrue);
      expect(controller.error, isNull);
      expect(notified, isTrue);
    });

    test('should auto-configure for different formats', () {
      // Test comics auto-configuration
      const comicsContent = MediaContent(
        id: '1', name: 'Comics', filePath: 'test.comics', format: MediaFormat.comics,
      );

      controller.loadMediaContent(comicsContent);
      expect(controller.config.enableAR, isFalse);
      expect(controller.config.autoRotate, isFalse);
      expect(controller.config.backgroundColor, equals(0xFF000000));

      // Test 3D model auto-configuration
      const modelContent = MediaContent(
        id: '2', name: 'Model', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(modelContent);
      expect(controller.config.enableAR, isTrue);
      expect(controller.config.autoRotate, isTrue);
      expect(controller.config.cameraControls, isTrue);
    });

    test('should handle play/pause/stop states', () async {
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      // Test play
      await controller.play();
      expect(controller.isPlaying, isTrue);

      // Test pause
      controller.pause();
      expect(controller.isPlaying, isFalse);

      // Test resume
      controller.resume();
      expect(controller.isPlaying, isTrue);

      // Test stop
      controller.stop();
      expect(controller.isPlaying, isFalse);
    });

    test('should toggle play/pause correctly', () async {
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      // Initially not playing
      expect(controller.isPlaying, isFalse);

      // Toggle to play
      controller.togglePlayPause();
      expect(controller.isPlaying, isTrue);

      // Toggle to pause
      controller.togglePlayPause();
      expect(controller.isPlaying, isFalse);
    });

    test('should clear content correctly', () {
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);
      expect(controller.hasContent, isTrue);

      bool notified = false;
      controller.addListener(() {
        notified = true;
      });

      controller.clearContent();

      expect(controller.currentContent, isNull);
      expect(controller.hasContent, isFalse);
      expect(controller.isPlaying, isFalse);
      expect(controller.error, isNull);
      expect(notified, isTrue);
    });

    test('should switch playback modes correctly', () {
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(content);

      // Test switching to AR mode
      controller.switchPlaybackMode(PlaybackMode.ar);
      expect(controller.currentContent!.playbackMode, equals(PlaybackMode.ar));
      expect(controller.config.enableAR, isTrue);
      expect(controller.config.enableDomeProjection, isFalse);

      // Test switching to dome mode
      controller.switchPlaybackMode(PlaybackMode.dome);
      expect(controller.currentContent!.playbackMode, equals(PlaybackMode.dome));
      expect(controller.config.enableDomeProjection, isTrue);
      expect(controller.config.enableAR, isFalse);
    });

    test('should reject unsupported playback modes', () {
      const content = MediaContent(
        id: 'test', name: 'Comics', filePath: 'test.comics', format: MediaFormat.comics,
      );

      controller.loadMediaContent(content);

      // Comics don't support AR
      controller.switchPlaybackMode(PlaybackMode.ar);
      expect(controller.error, isNotNull);
      expect(controller.error!.contains('не поддерживается'), isTrue);
    });

    test('should get available playback modes correctly', () {
      // Test for comics
      const comicsContent = MediaContent(
        id: '1', name: 'Comics', filePath: 'test.comics', format: MediaFormat.comics,
      );

      controller.loadMediaContent(comicsContent);
      final comicsModes = controller.getAvailablePlaybackModes();
      expect(comicsModes, equals([PlaybackMode.screen]));

      // Test for 3D model
      const modelContent = MediaContent(
        id: '2', name: 'Model', filePath: 'test.dae', format: MediaFormat.collada,
      );

      controller.loadMediaContent(modelContent);
      final modelModes = controller.getAvailablePlaybackModes();
      expect(modelModes, contains(PlaybackMode.screen));
      expect(modelModes, contains(PlaybackMode.dome));
      expect(modelModes, contains(PlaybackMode.ar));

      // Test for boranko
      const borankoContent = MediaContent(
        id: '3', name: 'Boranko', filePath: 'test.boranko', format: MediaFormat.boranko,
      );

      controller.loadMediaContent(borankoContent);
      final borankoModes = controller.getAvailablePlaybackModes();
      expect(borankoModes, contains(PlaybackMode.screen));
      expect(borankoModes, contains(PlaybackMode.dome));
      expect(borankoModes, contains(PlaybackMode.vr));
    });

    test('should handle no content gracefully', () {
      expect(controller.getAvailablePlaybackModes(), equals([PlaybackMode.screen]));
      
      // These should not crash when no content is loaded
      controller.togglePlayPause();
      controller.stop();
      controller.pause();
      controller.resume();
      controller.switchPlaybackMode(PlaybackMode.ar);
    });

    test('should notify listeners on state changes', () {
      int notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      // Load content
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );
      controller.loadMediaContent(content);
      expect(notificationCount, equals(1));

      // Update config
      const newConfig = PlayerConfig(enableAR: false);
      controller.updateConfig(newConfig);
      expect(notificationCount, equals(2));

      // Clear content
      controller.clearContent();
      expect(notificationCount, equals(3));
    });

    test('should handle format-specific configurations', () {
      // Test Boranko format
      const borankoContent = MediaContent(
        id: '1', name: 'Boranko', filePath: 'test.boranko', format: MediaFormat.boranko,
      );

      controller.loadMediaContent(borankoContent);
      expect(controller.config.enableDomeProjection, isTrue);
      expect(controller.config.enableVR, isTrue);
      expect(controller.config.backgroundColor, equals(0xFF000000));

      // Test Comics format
      const comicsContent = MediaContent(
        id: '2', name: 'Comics', filePath: 'test.comics', format: MediaFormat.comics,
      );

      controller.loadMediaContent(comicsContent);
      expect(controller.config.enableAR, isFalse);
      expect(controller.config.enableVR, isFalse);
      expect(controller.config.autoRotate, isFalse);
    });

    test('should maintain state consistency', () {
      const content = MediaContent(
        id: 'test', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      // Load content and play
      controller.loadMediaContent(content);
      controller.togglePlayPause();
      
      expect(controller.hasContent, isTrue);
      expect(controller.isPlaying, isTrue);
      expect(controller.error, isNull);

      // Clear content should stop playback
      controller.clearContent();
      expect(controller.hasContent, isFalse);
      expect(controller.isPlaying, isFalse);
    });

    test('should handle unknown format gracefully', () {
      const unknownContent = MediaContent(
        id: 'test', name: 'Unknown', filePath: 'test.unknown', format: MediaFormat.unknown,
      );

      controller.loadMediaContent(unknownContent);
      
      // Should not crash and should have basic config
      expect(controller.hasContent, isTrue);
      expect(controller.config, isA<PlayerConfig>());
    });
  });
}
