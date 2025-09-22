import 'package:flutter/foundation.dart';
import 'dome_config.dart';

/// Конфигурация плеера FreeDome
@immutable
class PlayerConfig {
  /// Включить AR функциональность
  final bool enableAR;

  /// Включить VR функциональность
  final bool enableVR;

  /// Включить купольную проекцию
  final bool enableDomeProjection;

  /// Автоматически поворачивать 3D модели
  final bool autoRotate;

  /// Включить элементы управления камерой
  final bool cameraControls;

  /// Цвет фона
  final int backgroundColor;

  /// Качество рендеринга (0.1 - 2.0)
  final double renderQuality;

  /// Конфигурация купола
  final DomeConfig? domeConfig;

  /// Дополнительные настройки
  final Map<String, dynamic>? additionalSettings;

  const PlayerConfig({
    this.enableAR = true,
    this.enableVR = false,
    this.enableDomeProjection = false,
    this.autoRotate = true,
    this.cameraControls = true,
    this.backgroundColor = 0xFF2A2A2A,
    this.renderQuality = 1.0,
    this.domeConfig,
    this.additionalSettings,
  });

  /// Создать конфигурацию из JSON
  factory PlayerConfig.fromJson(Map<String, dynamic> json) {
    return PlayerConfig(
      enableAR: json['enableAR'] ?? true,
      enableVR: json['enableVR'] ?? false,
      enableDomeProjection: json['enableDomeProjection'] ?? false,
      autoRotate: json['autoRotate'] ?? true,
      cameraControls: json['cameraControls'] ?? true,
      backgroundColor: json['backgroundColor'] ?? 0xFF2A2A2A,
      renderQuality: (json['renderQuality'] ?? 1.0).toDouble(),
      domeConfig: json['domeConfig'] != null
          ? DomeConfig.fromJson(json['domeConfig'])
          : null,
      additionalSettings: json['additionalSettings'],
    );
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'enableAR': enableAR,
      'enableVR': enableVR,
      'enableDomeProjection': enableDomeProjection,
      'autoRotate': autoRotate,
      'cameraControls': cameraControls,
      'backgroundColor': backgroundColor,
      'renderQuality': renderQuality,
      'domeConfig': domeConfig?.toJson(),
      'additionalSettings': additionalSettings,
    };
  }

  /// Создать копию с измененными параметрами
  PlayerConfig copyWith({
    bool? enableAR,
    bool? enableVR,
    bool? enableDomeProjection,
    bool? autoRotate,
    bool? cameraControls,
    int? backgroundColor,
    double? renderQuality,
    DomeConfig? domeConfig,
    Map<String, dynamic>? additionalSettings,
  }) {
    return PlayerConfig(
      enableAR: enableAR ?? this.enableAR,
      enableVR: enableVR ?? this.enableVR,
      enableDomeProjection: enableDomeProjection ?? this.enableDomeProjection,
      autoRotate: autoRotate ?? this.autoRotate,
      cameraControls: cameraControls ?? this.cameraControls,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      renderQuality: renderQuality ?? this.renderQuality,
      domeConfig: domeConfig ?? this.domeConfig,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// Конфигурация по умолчанию для 3D моделей
  static const PlayerConfig default3D = PlayerConfig(
    enableAR: true,
    enableVR: false,
    enableDomeProjection: false,
    autoRotate: true,
    cameraControls: true,
    backgroundColor: 0xFF2A2A2A,
    renderQuality: 1.0,
  );

  /// Конфигурация для комиксов
  static const PlayerConfig defaultComics = PlayerConfig(
    enableAR: false,
    enableVR: false,
    enableDomeProjection: false,
    autoRotate: false,
    cameraControls: false,
    backgroundColor: 0xFF000000,
    renderQuality: 1.0,
  );

  /// Конфигурация для купольной проекции
  static PlayerConfig domeProjection(DomeConfig domeConfig) {
    return PlayerConfig(
      enableAR: false,
      enableVR: false,
      enableDomeProjection: true,
      autoRotate: false,
      cameraControls: true,
      backgroundColor: 0xFF000000,
      renderQuality: 1.5,
      domeConfig: domeConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerConfig &&
        other.enableAR == enableAR &&
        other.enableVR == enableVR &&
        other.enableDomeProjection == enableDomeProjection &&
        other.autoRotate == autoRotate &&
        other.cameraControls == cameraControls &&
        other.backgroundColor == backgroundColor &&
        other.renderQuality == renderQuality &&
        other.domeConfig == domeConfig;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableAR,
      enableVR,
      enableDomeProjection,
      autoRotate,
      cameraControls,
      backgroundColor,
      renderQuality,
      domeConfig,
    );
  }

  @override
  String toString() {
    return 'PlayerConfig(enableAR: $enableAR, enableVR: $enableVR, enableDomeProjection: $enableDomeProjection)';
  }
}
