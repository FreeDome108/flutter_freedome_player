import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/services/format_detector_service.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';

void main() {
  group('FormatDetectorService', () {
    late FormatDetectorService service;

    setUp(() {
      service = FormatDetectorService();
    });

    test('should detect format by file extension correctly', () {
      final testCases = {
        'test.comics': MediaFormat.comics,
        'path/to/file.comics': MediaFormat.comics,
        'test.boranko': MediaFormat.boranko,
        'assets/content.boranko': MediaFormat.boranko,
        'model.dae': MediaFormat.collada,
        'assets/models/buddha.dae': MediaFormat.collada,
        'simple.obj': MediaFormat.obj,
        'scene.gltf': MediaFormat.gltf,
        'binary.glb': MediaFormat.glb,
        'unknown.txt': MediaFormat.unknown,
        'noextension': MediaFormat.unknown,
        '': MediaFormat.unknown,
      };

      for (final entry in testCases.entries) {
        final detected = service.detectFormat(entry.key);
        expect(
          detected,
          equals(entry.value),
          reason: 'Failed for file: ${entry.key}',
        );
      }
    });

    test('should handle case insensitive extensions', () {
      final testCases = [
        'test.COMICS',
        'test.Comics',
        'test.cOmIcS',
        'MODEL.DAE',
        'Scene.GLTF',
        'Binary.GLB',
      ];

      for (final filePath in testCases) {
        final detected = service.detectFormat(filePath);
        expect(
          detected,
          isNot(equals(MediaFormat.unknown)),
          reason: 'Should detect format for: $filePath',
        );
      }
    });

    test('should check if format is supported', () {
      expect(service.isFormatSupported('test.comics'), isTrue);
      expect(service.isFormatSupported('model.dae'), isTrue);
      expect(service.isFormatSupported('scene.gltf'), isTrue);
      expect(service.isFormatSupported('unknown.txt'), isFalse);
      expect(service.isFormatSupported(''), isFalse);
    });

    test('should return correct supported extensions', () {
      final extensions = service.getSupportedExtensions();

      expect(extensions, contains('.comics'));
      expect(extensions, contains('.boranko'));
      expect(extensions, contains('.dae'));
      expect(extensions, contains('.obj'));
      expect(extensions, contains('.gltf'));
      expect(extensions, contains('.glb'));
      expect(extensions.length, equals(6));
    });

    test('should provide format descriptions', () {
      final descriptions = {
        MediaFormat.comics:
            'Comics format - ZIP archive with images and metadata',
        MediaFormat.boranko:
            'Boranko format - Advanced 2D format with Z-depth for dome projection',
        MediaFormat.collada: 'COLLADA format - XML-based 3D model format',
        MediaFormat.obj: 'OBJ format - Simple 3D model format',
        MediaFormat.gltf: 'glTF format - Modern 3D transmission format',
        MediaFormat.glb: 'glTF Binary format - Binary version of glTF',
        MediaFormat.unknown: 'Unknown format',
      };

      for (final entry in descriptions.entries) {
        final description = service.getFormatDescription(entry.key);
        expect(description, equals(entry.value));
      }
    });

    test('should identify 3D formats correctly', () {
      expect(service.is3DFormat(MediaFormat.collada), isTrue);
      expect(service.is3DFormat(MediaFormat.obj), isTrue);
      expect(service.is3DFormat(MediaFormat.gltf), isTrue);
      expect(service.is3DFormat(MediaFormat.glb), isTrue);
      expect(service.is3DFormat(MediaFormat.comics), isFalse);
      expect(service.is3DFormat(MediaFormat.boranko), isFalse);
      expect(service.is3DFormat(MediaFormat.unknown), isFalse);
    });

    test('should identify 2D formats correctly', () {
      expect(service.is2DFormat(MediaFormat.comics), isTrue);
      expect(service.is2DFormat(MediaFormat.boranko), isTrue);
      expect(service.is2DFormat(MediaFormat.collada), isFalse);
      expect(service.is2DFormat(MediaFormat.obj), isFalse);
      expect(service.is2DFormat(MediaFormat.gltf), isFalse);
      expect(service.is2DFormat(MediaFormat.glb), isFalse);
      expect(service.is2DFormat(MediaFormat.unknown), isFalse);
    });

    test('should identify dome projection support', () {
      expect(service.supportsDomeProjection(MediaFormat.boranko), isTrue);
      expect(service.supportsDomeProjection(MediaFormat.collada), isTrue);
      expect(service.supportsDomeProjection(MediaFormat.obj), isTrue);
      expect(service.supportsDomeProjection(MediaFormat.gltf), isTrue);
      expect(service.supportsDomeProjection(MediaFormat.glb), isTrue);
      expect(service.supportsDomeProjection(MediaFormat.comics), isFalse);
      expect(service.supportsDomeProjection(MediaFormat.unknown), isFalse);
    });

    test('should identify AR support', () {
      expect(service.supportsAR(MediaFormat.collada), isTrue);
      expect(service.supportsAR(MediaFormat.obj), isTrue);
      expect(service.supportsAR(MediaFormat.gltf), isTrue);
      expect(service.supportsAR(MediaFormat.glb), isTrue);
      expect(service.supportsAR(MediaFormat.comics), isFalse);
      expect(service.supportsAR(MediaFormat.boranko), isFalse);
      expect(service.supportsAR(MediaFormat.unknown), isFalse);
    });

    test('should identify VR support', () {
      expect(service.supportsVR(MediaFormat.boranko), isTrue);
      expect(service.supportsVR(MediaFormat.collada), isTrue);
      expect(service.supportsVR(MediaFormat.obj), isTrue);
      expect(service.supportsVR(MediaFormat.gltf), isTrue);
      expect(service.supportsVR(MediaFormat.glb), isTrue);
      expect(service.supportsVR(MediaFormat.comics), isFalse);
      expect(service.supportsVR(MediaFormat.unknown), isFalse);
    });

    test('should provide recommended player settings for each format', () {
      // Test comics settings
      final comicsSettings = service.getRecommendedPlayerSettings(
        MediaFormat.comics,
      );
      expect(comicsSettings['enableAR'], isFalse);
      expect(comicsSettings['enableVR'], isFalse);
      expect(comicsSettings['enableDomeProjection'], isFalse);
      expect(comicsSettings['autoRotate'], isFalse);
      expect(comicsSettings['backgroundColor'], equals(0xFF000000));

      // Test boranko settings
      final borankoSettings = service.getRecommendedPlayerSettings(
        MediaFormat.boranko,
      );
      expect(borankoSettings['enableVR'], isTrue);
      expect(borankoSettings['enableDomeProjection'], isTrue);
      expect(borankoSettings['backgroundColor'], equals(0xFF000000));

      // Test 3D model settings
      final colladaSettings = service.getRecommendedPlayerSettings(
        MediaFormat.collada,
      );
      expect(colladaSettings['enableAR'], isTrue);
      expect(colladaSettings['enableDomeProjection'], isTrue);
      expect(colladaSettings['autoRotate'], isTrue);
      expect(colladaSettings['cameraControls'], isTrue);
      expect(colladaSettings['backgroundColor'], equals(0xFF2A2A2A));

      // Test unknown format settings
      final unknownSettings = service.getRecommendedPlayerSettings(
        MediaFormat.unknown,
      );
      expect(unknownSettings['enableAR'], isFalse);
      expect(unknownSettings['enableVR'], isFalse);
      expect(unknownSettings['enableDomeProjection'], isFalse);
    });

    test('should handle edge cases', () {
      // Empty string
      expect(service.detectFormat(''), equals(MediaFormat.unknown));

      // No extension
      expect(service.detectFormat('filename'), equals(MediaFormat.unknown));

      // Multiple dots
      expect(
        service.detectFormat('file.backup.dae'),
        equals(MediaFormat.collada),
      );

      // Hidden files
      expect(
        service.detectFormat('.hidden.comics'),
        equals(MediaFormat.comics),
      );

      // Path with spaces
      expect(
        service.detectFormat('path with spaces/file.boranko'),
        equals(MediaFormat.boranko),
      );
    });

    test('should be singleton', () {
      final service1 = FormatDetectorService();
      final service2 = FormatDetectorService();

      expect(identical(service1, service2), isTrue);
    });
  });
}
