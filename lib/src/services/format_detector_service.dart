import 'package:path/path.dart' as path;
import '../models/media_content.dart';

/// Сервис для определения формата медиа файлов
class FormatDetectorService {
  static final FormatDetectorService _instance =
      FormatDetectorService._internal();
  factory FormatDetectorService() => _instance;
  FormatDetectorService._internal();

  /// Определить формат файла по расширению
  MediaFormat detectFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.comics':
        return MediaFormat.comics;
      case '.boranko':
        return MediaFormat.boranko;
      case '.dae':
        return MediaFormat.collada;
      case '.obj':
        return MediaFormat.obj;
      case '.gltf':
        return MediaFormat.gltf;
      case '.glb':
        return MediaFormat.glb;
      default:
        return MediaFormat.unknown;
    }
  }

  /// Проверить, поддерживается ли формат
  bool isFormatSupported(String filePath) {
    return detectFormat(filePath) != MediaFormat.unknown;
  }

  /// Получить список поддерживаемых расширений
  List<String> getSupportedExtensions() {
    return [
      '.comics',
      '.boranko',
      '.dae',
      '.obj',
      '.gltf',
      '.glb',
    ];
  }

  /// Получить описание формата
  String getFormatDescription(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        return 'Comics format - ZIP archive with images and metadata';
      case MediaFormat.boranko:
        return 'Boranko format - Advanced 2D format with Z-depth for dome projection';
      case MediaFormat.collada:
        return 'COLLADA format - XML-based 3D model format';
      case MediaFormat.obj:
        return 'OBJ format - Simple 3D model format';
      case MediaFormat.gltf:
        return 'glTF format - Modern 3D transmission format';
      case MediaFormat.glb:
        return 'glTF Binary format - Binary version of glTF';
      case MediaFormat.unknown:
        return 'Unknown format';
    }
  }

  /// Проверить, является ли формат 3D
  bool is3DFormat(MediaFormat format) {
    return [
      MediaFormat.collada,
      MediaFormat.obj,
      MediaFormat.gltf,
      MediaFormat.glb,
    ].contains(format);
  }

  /// Проверить, является ли формат 2D
  bool is2DFormat(MediaFormat format) {
    return [
      MediaFormat.comics,
      MediaFormat.boranko,
    ].contains(format);
  }

  /// Проверить, поддерживает ли формат купольную проекцию
  bool supportsDomeProjection(MediaFormat format) {
    return format == MediaFormat.boranko || is3DFormat(format);
  }

  /// Проверить, поддерживает ли формат AR
  bool supportsAR(MediaFormat format) {
    return is3DFormat(format);
  }

  /// Проверить, поддерживает ли формат VR
  bool supportsVR(MediaFormat format) {
    return is3DFormat(format) || format == MediaFormat.boranko;
  }

  /// Получить рекомендуемые настройки плеера для формата
  Map<String, dynamic> getRecommendedPlayerSettings(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        return {
          'enableAR': false,
          'enableVR': false,
          'enableDomeProjection': false,
          'autoRotate': false,
          'cameraControls': false,
          'backgroundColor': 0xFF000000,
        };
      case MediaFormat.boranko:
        return {
          'enableAR': false,
          'enableVR': true,
          'enableDomeProjection': true,
          'autoRotate': false,
          'cameraControls': true,
          'backgroundColor': 0xFF000000,
        };
      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        return {
          'enableAR': true,
          'enableVR': false,
          'enableDomeProjection': true,
          'autoRotate': true,
          'cameraControls': true,
          'backgroundColor': 0xFF2A2A2A,
        };
      case MediaFormat.unknown:
        return {
          'enableAR': false,
          'enableVR': false,
          'enableDomeProjection': false,
          'autoRotate': false,
          'cameraControls': false,
          'backgroundColor': 0xFF000000,
        };
    }
  }
}
