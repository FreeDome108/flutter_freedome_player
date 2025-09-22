import 'package:flutter/foundation.dart';

/// Типы поддерживаемых медиа форматов
enum MediaFormat {
  comics,
  boranko,
  collada,
  obj,
  gltf,
  glb,
  unknown,
}

/// Режимы проигрывания
enum PlaybackMode {
  screen, // Обычное отображение на экране
  dome, // Купольная проекция
  ar, // Дополненная реальность
  vr, // Виртуальная реальность
}

/// Модель медиа контента
@immutable
class MediaContent {
  final String id;
  final String name;
  final String filePath;
  final MediaFormat format;
  final PlaybackMode playbackMode;
  final Map<String, dynamic>? metadata;
  final Duration? duration;
  final List<String>? tags;
  final String? description;
  final String? author;
  final DateTime? createdAt;

  const MediaContent({
    required this.id,
    required this.name,
    required this.filePath,
    required this.format,
    this.playbackMode = PlaybackMode.screen,
    this.metadata,
    this.duration,
    this.tags,
    this.description,
    this.author,
    this.createdAt,
  });

  /// Создать медиа контент из JSON
  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      filePath: json['filePath'] ?? '',
      format: _parseFormat(json['format']),
      playbackMode: _parsePlaybackMode(json['playbackMode']),
      metadata: json['metadata'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      tags: json['tags']?.cast<String>(),
      description: json['description'],
      author: json['author'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'format': format.name,
      'playbackMode': playbackMode.name,
      'metadata': metadata,
      'duration': duration?.inMilliseconds,
      'tags': tags,
      'description': description,
      'author': author,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Создать копию с измененными параметрами
  MediaContent copyWith({
    String? id,
    String? name,
    String? filePath,
    MediaFormat? format,
    PlaybackMode? playbackMode,
    Map<String, dynamic>? metadata,
    Duration? duration,
    List<String>? tags,
    String? description,
    String? author,
    DateTime? createdAt,
  }) {
    return MediaContent(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      format: format ?? this.format,
      playbackMode: playbackMode ?? this.playbackMode,
      metadata: metadata ?? this.metadata,
      duration: duration ?? this.duration,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Проверить, является ли контент 3D
  bool get is3D {
    return [
      MediaFormat.collada,
      MediaFormat.obj,
      MediaFormat.gltf,
      MediaFormat.glb,
    ].contains(format);
  }

  /// Проверить, является ли контент 2D
  bool get is2D {
    return [
      MediaFormat.comics,
      MediaFormat.boranko,
    ].contains(format);
  }

  /// Проверить, поддерживает ли контент купольную проекцию
  bool get supportsDomeProjection {
    return format == MediaFormat.boranko || is3D;
  }

  /// Проверить, поддерживает ли контент AR
  bool get supportsAR {
    return is3D;
  }

  /// Проверить, поддерживает ли контент VR
  bool get supportsVR {
    return is3D || format == MediaFormat.boranko;
  }

  static MediaFormat _parseFormat(dynamic format) {
    if (format is String) {
      switch (format.toLowerCase()) {
        case 'comics':
          return MediaFormat.comics;
        case 'boranko':
          return MediaFormat.boranko;
        case 'collada':
        case 'dae':
          return MediaFormat.collada;
        case 'obj':
          return MediaFormat.obj;
        case 'gltf':
          return MediaFormat.gltf;
        case 'glb':
          return MediaFormat.glb;
        default:
          return MediaFormat.unknown;
      }
    }
    return MediaFormat.unknown;
  }

  static PlaybackMode _parsePlaybackMode(dynamic mode) {
    if (mode is String) {
      switch (mode.toLowerCase()) {
        case 'screen':
          return PlaybackMode.screen;
        case 'dome':
          return PlaybackMode.dome;
        case 'ar':
          return PlaybackMode.ar;
        case 'vr':
          return PlaybackMode.vr;
        default:
          return PlaybackMode.screen;
      }
    }
    return PlaybackMode.screen;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaContent &&
        other.id == id &&
        other.name == name &&
        other.filePath == filePath &&
        other.format == format &&
        other.playbackMode == playbackMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      filePath,
      format,
      playbackMode,
    );
  }

  @override
  String toString() {
    return 'MediaContent(id: $id, name: $name, format: $format, playbackMode: $playbackMode)';
  }
}
