import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/freedome_player.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';
import 'package:flutter_freedome_player/src/freedome_player_controller.dart';

void main() {
  group('FreeDome Player API Tests', () {
    late FreeDomePlayer player;

    setUp(() {
      player = FreeDomePlayer();
    });

    test('should be singleton', () {
      final player1 = FreeDomePlayer();
      final player2 = FreeDomePlayer();
      
      expect(identical(player1, player2), isTrue);
    });

    test('should check format support correctly', () {
      final supportedFiles = [
        'test.comics',
        'model.dae',
        'scene.gltf',
        'binary.glb',
        'simple.obj',
        'quantum.boranko',
      ];

      final unsupportedFiles = [
        'document.pdf',
        'image.jpg',
        'video.mp4',
        'audio.mp3',
        'text.txt',
      ];

      for (final file in supportedFiles) {
        expect(player.isFormatSupported(file), isTrue, 
               reason: '$file should be supported');
      }

      for (final file in unsupportedFiles) {
        expect(player.isFormatSupported(file), isFalse, 
               reason: '$file should not be supported');
      }
    });

    test('should return correct supported formats list', () {
      final formats = player.getSupportedFormats();
      
      expect(formats, hasLength(6));
      expect(formats, contains('comics'));
      expect(formats, contains('boranko'));
      expect(formats, contains('collada'));
      expect(formats, contains('obj'));
      expect(formats, contains('gltf'));
      expect(formats, contains('glb'));
    });

    test('should create controller with default config', () {
      final controller = player.createController();
      
      expect(controller, isA<FreeDomePlayerController>());
      expect(controller.config, isA<PlayerConfig>());
      expect(controller.hasContent, isFalse);
      expect(controller.isPlaying, isFalse);
    });

    test('should create controller with custom config', () {
      const customConfig = PlayerConfig(
        enableAR: false,
        enableVR: true,
        backgroundColor: 0xFF123456,
      );

      final controller = player.createController(customConfig);
      
      expect(controller.config, equals(customConfig));
    });

    test('should create MediaContent from file path', () {
      final content = FreeDomePlayer.createMediaContent(
        filePath: 'assets/test.dae',
        name: 'Test Model',
      );

      expect(content.filePath, equals('assets/test.dae'));
      expect(content.name, equals('Test Model'));
      expect(content.format, equals(MediaFormat.collada));
      expect(content.id, isNotNull);
      expect(content.createdAt, isNotNull);
    });

    test('should create MediaContent with all parameters', () {
      final content = FreeDomePlayer.createMediaContent(
        filePath: 'assets/comics.comics',
        name: 'Test Comics',
        format: MediaFormat.comics,
        playbackMode: PlaybackMode.screen,
        description: 'Test description',
        author: 'Test Author',
        tags: ['test', 'demo'],
      );

      expect(content.filePath, equals('assets/comics.comics'));
      expect(content.name, equals('Test Comics'));
      expect(content.format, equals(MediaFormat.comics));
      expect(content.playbackMode, equals(PlaybackMode.screen));
      expect(content.description, equals('Test description'));
      expect(content.author, equals('Test Author'));
      expect(content.tags, equals(['test', 'demo']));
    });

    test('should auto-detect format from file extension', () {
      final testCases = {
        'model.dae': MediaFormat.collada,
        'scene.obj': MediaFormat.obj,
        'modern.gltf': MediaFormat.gltf,
        'binary.glb': MediaFormat.glb,
        'story.comics': MediaFormat.comics,
        'quantum.boranko': MediaFormat.boranko,
        'unknown.xyz': MediaFormat.unknown,
      };

      for (final entry in testCases.entries) {
        final content = FreeDomePlayer.createMediaContent(
          filePath: entry.key,
        );
        expect(content.format, equals(entry.value), 
               reason: 'Failed for file: ${entry.key}');
      }
    });

    test('should extract name from file path', () {
      final testCases = {
        'assets/models/buddha_statue.dae': 'buddha statue',
        'path/to/my-model.obj': 'my model',
        'simple_scene.gltf': 'simple scene',
        'comics/chapter_1.comics': 'chapter 1',
        'test': 'test',
      };

      for (final entry in testCases.entries) {
        final content = FreeDomePlayer.createMediaContent(
          filePath: entry.key,
        );
        expect(content.name, equals(entry.value), 
               reason: 'Failed for path: ${entry.key}');
      }
    });

    test('should get recommended config for each format', () {
      // Test comics config
      final comicsConfig = player.getRecommendedConfig(MediaFormat.comics);
      expect(comicsConfig.enableAR, isFalse);
      expect(comicsConfig.autoRotate, isFalse);
      expect(comicsConfig.backgroundColor, equals(0xFF000000));

      // Test 3D model config
      final modelConfig = player.getRecommendedConfig(MediaFormat.collada);
      expect(modelConfig.enableAR, isTrue);
      expect(modelConfig.autoRotate, isTrue);
      expect(modelConfig.cameraControls, isTrue);

      // Test boranko config
      final borankoConfig = player.getRecommendedConfig(MediaFormat.boranko);
      expect(borankoConfig.enableDomeProjection, isTrue);
      expect(borankoConfig.enableVR, isTrue);
    });

    test('should handle debug logging', () {
      // Test enabling debug logging
      FreeDomePlayer.enableDebugLogging(true);
      
      // Test disabling debug logging
      FreeDomePlayer.enableDebugLogging(false);
      
      // Should not throw any errors
    });

    test('should create controller with content', () async {
      final controller = await player.createControllerWithContent(
        'assets/test.dae',
        const PlayerConfig(enableAR: true),
      );

      expect(controller, isA<FreeDomePlayerController>());
      expect(controller.config.enableAR, isTrue);
      // Note: Content loading is async and might not be complete immediately
    });

    test('should handle edge cases in file paths', () {
      final edgeCases = [
        '', // Empty string
        'no_extension',
        '.hidden_file.dae',
        'path with spaces/model.obj',
        'UPPERCASE.DAE',
        'mixed.Case.GLTF',
        'multiple.dots.in.name.comics',
      ];

      for (final path in edgeCases) {
        final content = FreeDomePlayer.createMediaContent(filePath: path);
        expect(content, isA<MediaContent>());
        expect(content.filePath, equals(path));
      }
    });

    test('should handle special characters in names', () {
      final specialNames = [
        'Model with spaces',
        'Model-with-dashes',
        'Model_with_underscores',
        'Model123',
        'Модель на русском',
        'モデル日本語',
        'Model with émojis 🎭',
      ];

      for (final name in specialNames) {
        final content = FreeDomePlayer.createMediaContent(
          filePath: 'test.dae',
          name: name,
        );
        expect(content.name, equals(name));
      }
    });

    test('should validate playback mode compatibility', () {
      // Comics should only support screen mode
      final comicsContent = FreeDomePlayer.createMediaContent(
        filePath: 'test.comics',
        format: MediaFormat.comics,
      );
      expect(comicsContent.supportsAR, isFalse);
      expect(comicsContent.supportsVR, isFalse);
      expect(comicsContent.supportsDomeProjection, isFalse);

      // 3D models should support AR and dome
      final modelContent = FreeDomePlayer.createMediaContent(
        filePath: 'test.dae',
        format: MediaFormat.collada,
      );
      expect(modelContent.supportsAR, isTrue);
      expect(modelContent.supportsVR, isTrue);
      expect(modelContent.supportsDomeProjection, isTrue);

      // Boranko should support VR and dome
      final borankoContent = FreeDomePlayer.createMediaContent(
        filePath: 'test.boranko',
        format: MediaFormat.boranko,
      );
      expect(borankoContent.supportsAR, isFalse);
      expect(borankoContent.supportsVR, isTrue);
      expect(borankoContent.supportsDomeProjection, isTrue);
    });

    test('should handle metadata correctly', () {
      final metadata = {
        'author': 'Test Author',
        'version': '1.0',
        'description': 'Test content',
        'tags': ['test', 'demo'],
        'custom_property': 'custom_value',
      };

      final content = FreeDomePlayer.createMediaContent(
        filePath: 'test.dae',
        metadata: metadata,
      );

      expect(content.metadata, equals(metadata));
    });

    test('should handle duration correctly', () {
      const duration = Duration(minutes: 5, seconds: 30);
      
      final content = FreeDomePlayer.createMediaContent(
        filePath: 'test.comics',
        duration: duration,
      );

      expect(content.duration, equals(duration));
    });

    test('should handle tags correctly', () {
      final tags = ['3d', 'ar', 'meditation', 'spiritual'];
      
      final content = FreeDomePlayer.createMediaContent(
        filePath: 'test.boranko',
        tags: tags,
      );

      expect(content.tags, equals(tags));
    });

    test('should validate content creation with various combinations', () {
      final combinations = [
        {
          'filePath': 'assets/buddha.dae',
          'format': MediaFormat.collada,
          'playbackMode': PlaybackMode.ar,
        },
        {
          'filePath': 'assets/comics.comics',
          'format': MediaFormat.comics,
          'playbackMode': PlaybackMode.screen,
        },
        {
          'filePath': 'assets/quantum.boranko',
          'format': MediaFormat.boranko,
          'playbackMode': PlaybackMode.dome,
        },
      ];

      for (final combo in combinations) {
        final content = FreeDomePlayer.createMediaContent(
          filePath: combo['filePath'] as String,
          format: combo['format'] as MediaFormat,
          playbackMode: combo['playbackMode'] as PlaybackMode,
        );

        expect(content.filePath, equals(combo['filePath']));
        expect(content.format, equals(combo['format']));
        expect(content.playbackMode, equals(combo['playbackMode']));
      }
    });
  });

  group('FreeDome Player Platform Capabilities', () {
    late FreeDomePlayer player;

    setUp(() {
      player = FreeDomePlayer();
    });

    test('should get platform capabilities', () async {
      final capabilities = await player.getPlatformCapabilities();
      
      expect(capabilities, isA<Map<String, bool>>());
      expect(capabilities.containsKey('ar_support'), isTrue);
      expect(capabilities.containsKey('vr_support'), isTrue);
      expect(capabilities.containsKey('dome_projection'), isTrue);
      expect(capabilities.containsKey('native_3d'), isTrue);
    });

    test('should handle capability check errors', () async {
      // This test ensures that capability checking doesn't crash
      final capabilities = await player.getPlatformCapabilities();
      
      // Should always return a map, even if some capabilities fail to check
      expect(capabilities, isA<Map<String, bool>>());
      expect(capabilities.isNotEmpty, isTrue);
    });
  });
}
