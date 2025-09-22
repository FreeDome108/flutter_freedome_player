import 'package:flutter/foundation.dart';

/// Типы купольных проекций
enum DomeProjectionType {
  fisheye,
  equirectangular,
  cubemap,
  spherical,
}

/// Конфигурация купольной проекции
@immutable
class DomeConfig {
  /// Тип проекции
  final DomeProjectionType projectionType;

  /// Радиус купола в метрах
  final double domeRadius;

  /// Количество проекторов
  final int projectorCount;

  /// Включить смешивание краев
  final bool edgeBlending;

  /// Включить цветовую коррекцию
  final bool colorCorrection;

  /// URL FreeDome Engine
  final String? freedomeEngineUrl;

  /// Порт OSC протокола
  final int oscPort;

  /// Хост OSC протокола
  final String oscHost;

  /// Квантовые свойства
  final QuantumProperties quantumProperties;

  const DomeConfig({
    this.projectionType = DomeProjectionType.fisheye,
    this.domeRadius = 5.0,
    this.projectorCount = 1,
    this.edgeBlending = false,
    this.colorCorrection = true,
    this.freedomeEngineUrl,
    this.oscPort = 8000,
    this.oscHost = 'localhost',
    this.quantumProperties = const QuantumProperties(),
  });

  /// Создать конфигурацию из JSON
  factory DomeConfig.fromJson(Map<String, dynamic> json) {
    return DomeConfig(
      projectionType: _parseProjectionType(json['projectionType']),
      domeRadius: (json['domeRadius'] ?? 5.0).toDouble(),
      projectorCount: json['projectorCount'] ?? 1,
      edgeBlending: json['edgeBlending'] ?? false,
      colorCorrection: json['colorCorrection'] ?? true,
      freedomeEngineUrl: json['freedomeEngineUrl'],
      oscPort: json['oscPort'] ?? 8000,
      oscHost: json['oscHost'] ?? 'localhost',
      quantumProperties: json['quantumProperties'] != null
          ? QuantumProperties.fromJson(json['quantumProperties'])
          : const QuantumProperties(),
    );
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'projectionType': projectionType.name,
      'domeRadius': domeRadius,
      'projectorCount': projectorCount,
      'edgeBlending': edgeBlending,
      'colorCorrection': colorCorrection,
      'freedomeEngineUrl': freedomeEngineUrl,
      'oscPort': oscPort,
      'oscHost': oscHost,
      'quantumProperties': quantumProperties.toJson(),
    };
  }

  /// Создать копию с измененными параметрами
  DomeConfig copyWith({
    DomeProjectionType? projectionType,
    double? domeRadius,
    int? projectorCount,
    bool? edgeBlending,
    bool? colorCorrection,
    String? freedomeEngineUrl,
    int? oscPort,
    String? oscHost,
    QuantumProperties? quantumProperties,
  }) {
    return DomeConfig(
      projectionType: projectionType ?? this.projectionType,
      domeRadius: domeRadius ?? this.domeRadius,
      projectorCount: projectorCount ?? this.projectorCount,
      edgeBlending: edgeBlending ?? this.edgeBlending,
      colorCorrection: colorCorrection ?? this.colorCorrection,
      freedomeEngineUrl: freedomeEngineUrl ?? this.freedomeEngineUrl,
      oscPort: oscPort ?? this.oscPort,
      oscHost: oscHost ?? this.oscHost,
      quantumProperties: quantumProperties ?? this.quantumProperties,
    );
  }

  static DomeProjectionType _parseProjectionType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'fisheye':
          return DomeProjectionType.fisheye;
        case 'equirectangular':
          return DomeProjectionType.equirectangular;
        case 'cubemap':
          return DomeProjectionType.cubemap;
        case 'spherical':
          return DomeProjectionType.spherical;
        default:
          return DomeProjectionType.fisheye;
      }
    }
    return DomeProjectionType.fisheye;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomeConfig &&
        other.projectionType == projectionType &&
        other.domeRadius == domeRadius &&
        other.projectorCount == projectorCount &&
        other.edgeBlending == edgeBlending &&
        other.colorCorrection == colorCorrection &&
        other.freedomeEngineUrl == freedomeEngineUrl &&
        other.oscPort == oscPort &&
        other.oscHost == oscHost &&
        other.quantumProperties == quantumProperties;
  }

  @override
  int get hashCode {
    return Object.hash(
      projectionType,
      domeRadius,
      projectorCount,
      edgeBlending,
      colorCorrection,
      freedomeEngineUrl,
      oscPort,
      oscHost,
      quantumProperties,
    );
  }

  @override
  String toString() {
    return 'DomeConfig(projectionType: $projectionType, domeRadius: $domeRadius, projectorCount: $projectorCount)';
  }
}

/// Квантовые свойства для купольной проекции
@immutable
class QuantumProperties {
  /// Резонансная частота
  final double resonanceFrequency;

  /// Паттерн интерференции
  final String interferencePattern;

  /// Уровень сознания
  final String consciousnessLevel;

  /// Количество квантовых элементов
  final int quantumElements;

  /// Фрактальное измерение
  final double fractalDimension;

  const QuantumProperties({
    this.resonanceFrequency = 108.0,
    this.interferencePattern = 'spiritual',
    this.consciousnessLevel = 'meditation',
    this.quantumElements = 108,
    this.fractalDimension = 2.618,
  });

  /// Создать квантовые свойства из JSON
  factory QuantumProperties.fromJson(Map<String, dynamic> json) {
    return QuantumProperties(
      resonanceFrequency: (json['resonanceFrequency'] ?? 108.0).toDouble(),
      interferencePattern: json['interferencePattern'] ?? 'spiritual',
      consciousnessLevel: json['consciousnessLevel'] ?? 'meditation',
      quantumElements: json['quantumElements'] ?? 108,
      fractalDimension: (json['fractalDimension'] ?? 2.618).toDouble(),
    );
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'resonanceFrequency': resonanceFrequency,
      'interferencePattern': interferencePattern,
      'consciousnessLevel': consciousnessLevel,
      'quantumElements': quantumElements,
      'fractalDimension': fractalDimension,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuantumProperties &&
        other.resonanceFrequency == resonanceFrequency &&
        other.interferencePattern == interferencePattern &&
        other.consciousnessLevel == consciousnessLevel &&
        other.quantumElements == quantumElements &&
        other.fractalDimension == fractalDimension;
  }

  @override
  int get hashCode {
    return Object.hash(
      resonanceFrequency,
      interferencePattern,
      consciousnessLevel,
      quantumElements,
      fractalDimension,
    );
  }

  @override
  String toString() {
    return 'QuantumProperties(resonanceFrequency: $resonanceFrequency, interferencePattern: $interferencePattern)';
  }
}
