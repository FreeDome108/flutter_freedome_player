import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/models/dome_config.dart';

void main() {
  group('DomeConfig', () {
    test('should create DomeConfig with default values', () {
      const config = DomeConfig();

      expect(config.projectionType, equals(DomeProjectionType.fisheye));
      expect(config.domeRadius, equals(5.0));
      expect(config.projectorCount, equals(1));
      expect(config.edgeBlending, isFalse);
      expect(config.colorCorrection, isTrue);
      expect(config.oscPort, equals(8000));
      expect(config.oscHost, equals('localhost'));
      expect(config.quantumProperties, isNotNull);
    });

    test('should create DomeConfig from JSON', () {
      final json = {
        'projectionType': 'equirectangular',
        'domeRadius': 12.5,
        'projectorCount': 4,
        'edgeBlending': true,
        'colorCorrection': false,
        'freedomeEngineUrl': 'http://dome.example.com:9000',
        'oscPort': 9000,
        'oscHost': '192.168.1.100',
        'quantumProperties': {
          'resonanceFrequency': 432.0,
          'interferencePattern': 'cosmic',
          'consciousnessLevel': 'enlightenment',
          'quantumElements': 216,
          'fractalDimension': 3.14159,
        },
      };

      final config = DomeConfig.fromJson(json);

      expect(config.projectionType, equals(DomeProjectionType.equirectangular));
      expect(config.domeRadius, equals(12.5));
      expect(config.projectorCount, equals(4));
      expect(config.edgeBlending, isTrue);
      expect(config.colorCorrection, isFalse);
      expect(config.freedomeEngineUrl, equals('http://dome.example.com:9000'));
      expect(config.oscPort, equals(9000));
      expect(config.oscHost, equals('192.168.1.100'));
      expect(config.quantumProperties.resonanceFrequency, equals(432.0));
      expect(config.quantumProperties.interferencePattern, equals('cosmic'));
    });

    test('should convert DomeConfig to JSON', () {
      const config = DomeConfig(
        projectionType: DomeProjectionType.cubemap,
        domeRadius: 8.0,
        projectorCount: 2,
        edgeBlending: true,
        freedomeEngineUrl: 'http://test.com',
        quantumProperties: QuantumProperties(
          resonanceFrequency: 528.0,
          interferencePattern: 'healing',
        ),
      );

      final json = config.toJson();

      expect(json['projectionType'], equals('cubemap'));
      expect(json['domeRadius'], equals(8.0));
      expect(json['projectorCount'], equals(2));
      expect(json['edgeBlending'], isTrue);
      expect(json['freedomeEngineUrl'], equals('http://test.com'));
      expect(json['quantumProperties']['resonanceFrequency'], equals(528.0));
      expect(
        json['quantumProperties']['interferencePattern'],
        equals('healing'),
      );
    });

    test('should parse projection type correctly', () {
      final testCases = {
        'fisheye': DomeProjectionType.fisheye,
        'FISHEYE': DomeProjectionType.fisheye,
        'equirectangular': DomeProjectionType.equirectangular,
        'cubemap': DomeProjectionType.cubemap,
        'spherical': DomeProjectionType.spherical,
        'unknown': DomeProjectionType.fisheye,
        'invalid': DomeProjectionType.fisheye,
      };

      for (final entry in testCases.entries) {
        final json = {'projectionType': entry.key};
        final config = DomeConfig.fromJson(json);
        expect(
          config.projectionType,
          equals(entry.value),
          reason: 'Failed for projection type: ${entry.key}',
        );
      }
    });

    test('should create copy with modified properties', () {
      const original = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        domeRadius: 5.0,
        projectorCount: 1,
      );

      final copy = original.copyWith(
        projectionType: DomeProjectionType.cubemap,
        domeRadius: 10.0,
      );

      expect(
        copy.projectionType,
        equals(DomeProjectionType.cubemap),
      ); // Changed
      expect(copy.domeRadius, equals(10.0)); // Changed
      expect(copy.projectorCount, equals(1)); // Unchanged
      expect(copy.edgeBlending, equals(original.edgeBlending)); // Unchanged
    });

    test('should handle equality correctly', () {
      const config1 = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        domeRadius: 5.0,
      );

      const config2 = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        domeRadius: 5.0,
      );

      const config3 = DomeConfig(
        projectionType: DomeProjectionType.cubemap,
        domeRadius: 5.0,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('QuantumProperties', () {
    test('should create QuantumProperties with default values', () {
      const props = QuantumProperties();

      expect(props.resonanceFrequency, equals(108.0));
      expect(props.interferencePattern, equals('spiritual'));
      expect(props.consciousnessLevel, equals('meditation'));
      expect(props.quantumElements, equals(108));
      expect(props.fractalDimension, equals(2.618));
    });

    test('should create QuantumProperties from JSON', () {
      final json = {
        'resonanceFrequency': 432.0,
        'interferencePattern': 'cosmic',
        'consciousnessLevel': 'enlightenment',
        'quantumElements': 216,
        'fractalDimension': 3.14159,
      };

      final props = QuantumProperties.fromJson(json);

      expect(props.resonanceFrequency, equals(432.0));
      expect(props.interferencePattern, equals('cosmic'));
      expect(props.consciousnessLevel, equals('enlightenment'));
      expect(props.quantumElements, equals(216));
      expect(props.fractalDimension, equals(3.14159));
    });

    test('should convert QuantumProperties to JSON', () {
      const props = QuantumProperties(
        resonanceFrequency: 528.0,
        interferencePattern: 'healing',
        consciousnessLevel: 'love',
        quantumElements: 144,
        fractalDimension: 1.618,
      );

      final json = props.toJson();

      expect(json['resonanceFrequency'], equals(528.0));
      expect(json['interferencePattern'], equals('healing'));
      expect(json['consciousnessLevel'], equals('love'));
      expect(json['quantumElements'], equals(144));
      expect(json['fractalDimension'], equals(1.618));
    });

    test('should handle equality correctly', () {
      const props1 = QuantumProperties(
        resonanceFrequency: 108.0,
        interferencePattern: 'spiritual',
      );

      const props2 = QuantumProperties(
        resonanceFrequency: 108.0,
        interferencePattern: 'spiritual',
      );

      const props3 = QuantumProperties(
        resonanceFrequency: 432.0,
        interferencePattern: 'spiritual',
      );

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('should serialize and deserialize correctly', () {
      const original = QuantumProperties(
        resonanceFrequency: 963.0,
        interferencePattern: 'crown_chakra',
        consciousnessLevel: 'cosmic',
        quantumElements: 777,
        fractalDimension: 2.718,
      );

      final json = original.toJson();
      final deserialized = QuantumProperties.fromJson(json);

      expect(deserialized, equals(original));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      final props = QuantumProperties.fromJson(json);

      expect(props.resonanceFrequency, equals(108.0));
      expect(props.interferencePattern, equals('spiritual'));
      expect(props.consciousnessLevel, equals('meditation'));
      expect(props.quantumElements, equals(108));
      expect(props.fractalDimension, equals(2.618));
    });
  });
}
