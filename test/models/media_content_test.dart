import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';

void main() {
  group('MediaContent', () {
    test('should create MediaContent with required fields', () {
      final content = MediaContent(
        id: 'test_id',
        name: 'Test Content',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      expect(content.id, equals('test_id'));
      expect(content.name, equals('Test Content'));
      expect(content.filePath, equals('assets/test.dae'));
      expect(content.format, equals(MediaFormat.collada));
      expect(content.playbackMode, equals(PlaybackMode.screen));
    });

    test('should create MediaContent from JSON', () {
      final json = {
        'id': 'json_id',
        'name': 'JSON Content',
        'filePath': 'assets/test.comics',
        'format': 'comics',
        'playbackMode': 'dome',
        'description': 'Test description',
        'author': 'Test Author',
        'duration': 5000,
      };

      final content = MediaContent.fromJson(json);

      expect(content.id, equals('json_id'));
      expect(content.name, equals('JSON Content'));
      expect(content.format, equals(MediaFormat.comics));
      expect(content.playbackMode, equals(PlaybackMode.dome));
      expect(content.description, equals('Test description'));
      expect(content.author, equals('Test Author'));
      expect(content.duration, equals(const Duration(milliseconds: 5000)));
    });

    test('should convert MediaContent to JSON', () {
      final content = MediaContent(
        id: 'test_id',
        name: 'Test Content',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
        playbackMode: PlaybackMode.vr,
        description: 'Test description',
        duration: const Duration(seconds: 30),
      );

      final json = content.toJson();

      expect(json['id'], equals('test_id'));
      expect(json['name'], equals('Test Content'));
      expect(json['format'], equals('boranko'));
      expect(json['playbackMode'], equals('vr'));
      expect(json['description'], equals('Test description'));
      expect(json['duration'], equals(30000));
    });

    test('should identify 3D formats correctly', () {
      final colladaContent = MediaContent(
        id: '1', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );
      final objContent = MediaContent(
        id: '2', name: 'Test', filePath: 'test.obj', format: MediaFormat.obj,
      );
      final gltfContent = MediaContent(
        id: '3', name: 'Test', filePath: 'test.gltf', format: MediaFormat.gltf,
      );
      final comicsContent = MediaContent(
        id: '4', name: 'Test', filePath: 'test.comics', format: MediaFormat.comics,
      );

      expect(colladaContent.is3D, isTrue);
      expect(objContent.is3D, isTrue);
      expect(gltfContent.is3D, isTrue);
      expect(comicsContent.is3D, isFalse);
    });

    test('should identify 2D formats correctly', () {
      final comicsContent = MediaContent(
        id: '1', name: 'Test', filePath: 'test.comics', format: MediaFormat.comics,
      );
      final borankoContent = MediaContent(
        id: '2', name: 'Test', filePath: 'test.boranko', format: MediaFormat.boranko,
      );
      final colladaContent = MediaContent(
        id: '3', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );

      expect(comicsContent.is2D, isTrue);
      expect(borankoContent.is2D, isTrue);
      expect(colladaContent.is2D, isFalse);
    });

    test('should identify dome projection support', () {
      final borankoContent = MediaContent(
        id: '1', name: 'Test', filePath: 'test.boranko', format: MediaFormat.boranko,
      );
      final colladaContent = MediaContent(
        id: '2', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );
      final comicsContent = MediaContent(
        id: '3', name: 'Test', filePath: 'test.comics', format: MediaFormat.comics,
      );

      expect(borankoContent.supportsDomeProjection, isTrue);
      expect(colladaContent.supportsDomeProjection, isTrue);
      expect(comicsContent.supportsDomeProjection, isFalse);
    });

    test('should identify AR support', () {
      final colladaContent = MediaContent(
        id: '1', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );
      final comicsContent = MediaContent(
        id: '2', name: 'Test', filePath: 'test.comics', format: MediaFormat.comics,
      );

      expect(colladaContent.supportsAR, isTrue);
      expect(comicsContent.supportsAR, isFalse);
    });

    test('should identify VR support', () {
      final borankoContent = MediaContent(
        id: '1', name: 'Test', filePath: 'test.boranko', format: MediaFormat.boranko,
      );
      final colladaContent = MediaContent(
        id: '2', name: 'Test', filePath: 'test.dae', format: MediaFormat.collada,
      );
      final comicsContent = MediaContent(
        id: '3', name: 'Test', filePath: 'test.comics', format: MediaFormat.comics,
      );

      expect(borankoContent.supportsVR, isTrue);
      expect(colladaContent.supportsVR, isTrue);
      expect(comicsContent.supportsVR, isFalse);
    });

    test('should create copy with modified properties', () {
      final original = MediaContent(
        id: 'original_id',
        name: 'Original',
        filePath: 'test.dae',
        format: MediaFormat.collada,
        playbackMode: PlaybackMode.screen,
      );

      final copy = original.copyWith(
        name: 'Modified',
        playbackMode: PlaybackMode.ar,
      );

      expect(copy.id, equals('original_id')); // Unchanged
      expect(copy.name, equals('Modified')); // Changed
      expect(copy.filePath, equals('test.dae')); // Unchanged
      expect(copy.format, equals(MediaFormat.collada)); // Unchanged
      expect(copy.playbackMode, equals(PlaybackMode.ar)); // Changed
    });

    test('should handle equality correctly', () {
      final content1 = MediaContent(
        id: 'test_id',
        name: 'Test',
        filePath: 'test.dae',
        format: MediaFormat.collada,
      );

      final content2 = MediaContent(
        id: 'test_id',
        name: 'Test',
        filePath: 'test.dae',
        format: MediaFormat.collada,
      );

      final content3 = MediaContent(
        id: 'different_id',
        name: 'Test',
        filePath: 'test.dae',
        format: MediaFormat.collada,
      );

      expect(content1, equals(content2));
      expect(content1, isNot(equals(content3)));
    });

    test('should parse format from string correctly', () {
      final testCases = {
        'comics': MediaFormat.comics,
        'COMICS': MediaFormat.comics,
        'boranko': MediaFormat.boranko,
        'collada': MediaFormat.collada,
        'dae': MediaFormat.collada,
        'obj': MediaFormat.obj,
        'gltf': MediaFormat.gltf,
        'glb': MediaFormat.glb,
        'unknown': MediaFormat.unknown,
        'invalid': MediaFormat.unknown,
      };

      for (final entry in testCases.entries) {
        final json = {'format': entry.key, 'id': 'test', 'name': 'test', 'filePath': 'test'};
        final content = MediaContent.fromJson(json);
        expect(content.format, equals(entry.value), reason: 'Failed for format: ${entry.key}');
      }
    });

    test('should parse playback mode from string correctly', () {
      final testCases = {
        'screen': PlaybackMode.screen,
        'SCREEN': PlaybackMode.screen,
        'dome': PlaybackMode.dome,
        'ar': PlaybackMode.ar,
        'vr': PlaybackMode.vr,
        'unknown': PlaybackMode.screen,
        'invalid': PlaybackMode.screen,
      };

      for (final entry in testCases.entries) {
        final json = {
          'playbackMode': entry.key,
          'id': 'test',
          'name': 'test',
          'filePath': 'test',
          'format': 'comics'
        };
        final content = MediaContent.fromJson(json);
        expect(content.playbackMode, equals(entry.value), reason: 'Failed for mode: ${entry.key}');
      }
    });
  });
}
