import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';
import 'package:flutter_freedome_player/src/models/dome_config.dart';

void main() {
  group('PlayerConfig', () {
    test('should create PlayerConfig with default values', () {
      const config = PlayerConfig();

      expect(config.enableAR, isTrue);
      expect(config.enableVR, isFalse);
      expect(config.enableDomeProjection, isFalse);
      expect(config.autoRotate, isTrue);
      expect(config.cameraControls, isTrue);
      expect(config.backgroundColor, equals(0xFF2A2A2A));
      expect(config.renderQuality, equals(1.0));
      expect(config.domeConfig, isNull);
    });

    test('should create PlayerConfig from JSON', () {
      final json = {
        'enableAR': false,
        'enableVR': true,
        'enableDomeProjection': true,
        'autoRotate': false,
        'cameraControls': false,
        'backgroundColor': 0xFF000000,
        'renderQuality': 1.5,
        'domeConfig': {
          'projectionType': 'fisheye',
          'domeRadius': 10.0,
          'projectorCount': 2,
        },
      };

      final config = PlayerConfig.fromJson(json);

      expect(config.enableAR, isFalse);
      expect(config.enableVR, isTrue);
      expect(config.enableDomeProjection, isTrue);
      expect(config.autoRotate, isFalse);
      expect(config.cameraControls, isFalse);
      expect(config.backgroundColor, equals(0xFF000000));
      expect(config.renderQuality, equals(1.5));
      expect(config.domeConfig, isNotNull);
      expect(config.domeConfig!.domeRadius, equals(10.0));
    });

    test('should convert PlayerConfig to JSON', () {
      const config = PlayerConfig(
        enableAR: false,
        enableVR: true,
        autoRotate: false,
        backgroundColor: 0xFF123456,
        renderQuality: 0.8,
      );

      final json = config.toJson();

      expect(json['enableAR'], isFalse);
      expect(json['enableVR'], isTrue);
      expect(json['autoRotate'], isFalse);
      expect(json['backgroundColor'], equals(0xFF123456));
      expect(json['renderQuality'], equals(0.8));
    });

    test('should create copy with modified properties', () {
      const original = PlayerConfig(
        enableAR: true,
        enableVR: false,
        backgroundColor: 0xFF000000,
      );

      final copy = original.copyWith(
        enableVR: true,
        backgroundColor: 0xFFFFFFFF,
      );

      expect(copy.enableAR, isTrue); // Unchanged
      expect(copy.enableVR, isTrue); // Changed
      expect(copy.backgroundColor, equals(0xFFFFFFFF)); // Changed
      expect(copy.autoRotate, equals(original.autoRotate)); // Unchanged
    });

    test('should provide correct default configurations', () {
      // Test default 3D config
      expect(PlayerConfig.default3D.enableAR, isTrue);
      expect(PlayerConfig.default3D.autoRotate, isTrue);
      expect(PlayerConfig.default3D.cameraControls, isTrue);

      // Test default comics config
      expect(PlayerConfig.defaultComics.enableAR, isFalse);
      expect(PlayerConfig.defaultComics.autoRotate, isFalse);
      expect(PlayerConfig.defaultComics.cameraControls, isFalse);
      expect(PlayerConfig.defaultComics.backgroundColor, equals(0xFF000000));
    });

    test('should create dome projection config', () {
      const domeConfig = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        domeRadius: 8.0,
      );

      final playerConfig = PlayerConfig.domeProjection(domeConfig);

      expect(playerConfig.enableDomeProjection, isTrue);
      expect(playerConfig.enableAR, isFalse);
      expect(playerConfig.enableVR, isFalse);
      expect(playerConfig.domeConfig, equals(domeConfig));
      expect(playerConfig.renderQuality, equals(1.5));
    });

    test('should handle equality correctly', () {
      const config1 = PlayerConfig(
        enableAR: true,
        backgroundColor: 0xFF000000,
      );

      const config2 = PlayerConfig(
        enableAR: true,
        backgroundColor: 0xFF000000,
      );

      const config3 = PlayerConfig(
        enableAR: false,
        backgroundColor: 0xFF000000,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should validate render quality bounds', () {
      // Test normal values
      const config1 = PlayerConfig(renderQuality: 0.5);
      const config2 = PlayerConfig(renderQuality: 1.0);
      const config3 = PlayerConfig(renderQuality: 2.0);

      expect(config1.renderQuality, equals(0.5));
      expect(config2.renderQuality, equals(1.0));
      expect(config3.renderQuality, equals(2.0));

      // Constructor doesn't validate bounds, but we can test the values
      const extremeConfig = PlayerConfig(renderQuality: 10.0);
      expect(extremeConfig.renderQuality, equals(10.0));
    });

    test('should handle null dome config', () {
      const config = PlayerConfig(
        enableDomeProjection: true,
        domeConfig: null,
      );

      expect(config.enableDomeProjection, isTrue);
      expect(config.domeConfig, isNull);
    });

    test('should serialize and deserialize correctly', () {
      const domeConfig = DomeConfig(
        projectionType: DomeProjectionType.equirectangular,
        domeRadius: 7.5,
        quantumProperties: QuantumProperties(
          resonanceFrequency: 432.0,
          interferencePattern: 'cosmic',
        ),
      );

      const original = PlayerConfig(
        enableAR: true,
        enableVR: true,
        enableDomeProjection: true,
        backgroundColor: 0xFF123456,
        renderQuality: 1.2,
        domeConfig: domeConfig,
      );

      final json = original.toJson();
      final deserialized = PlayerConfig.fromJson(json);

      expect(deserialized.enableAR, equals(original.enableAR));
      expect(deserialized.enableVR, equals(original.enableVR));
      expect(deserialized.enableDomeProjection, equals(original.enableDomeProjection));
      expect(deserialized.backgroundColor, equals(original.backgroundColor));
      expect(deserialized.renderQuality, equals(original.renderQuality));
      expect(deserialized.domeConfig, equals(original.domeConfig));
    });
  });
}
