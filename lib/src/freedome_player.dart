import 'package:flutter/foundation.dart';

import 'flutter_freedome_player_platform_interface.dart';
import 'models/media_content.dart';
import 'models/player_config.dart';
import 'freedome_player_controller.dart';

/// Основной класс FreeDome плеера
class FreeDomePlayer {
  static final FreeDomePlayer _instance = FreeDomePlayer._internal();
  factory FreeDomePlayer() => _instance;
  FreeDomePlayer._internal();

  /// Получить версию платформы
  Future<String?> getPlatformVersion() {
    return FlutterFreedomePlayerPlatform.instance.getPlatformVersion();
  }

  /// Инициализировать нативный 3D рендерер
  Future<bool> initializeRenderer() {
    return FlutterFreedomePlayerPlatform.instance.initializeRenderer();
  }

  /// Создать контроллер плеера
  FreeDomePlayerController createController([PlayerConfig? config]) {
    final controller = FreeDomePlayerController();
    if (config != null) {
      controller.updateConfig(config);
    }
    return controller;
  }

  /// Создать контроллер с предзагруженным контентом
  Future<FreeDomePlayerController> createControllerWithContent(
    String filePath, [
    PlayerConfig? config,
  ]) async {
    final controller = createController(config);
    await controller.loadContent(filePath);
    return controller;
  }

  /// Проверить поддержку формата
  bool isFormatSupported(String filePath) {
    final supportedExtensions = [
      '.comics',
      '.boranko',
      '.dae',
      '.obj',
      '.gltf',
      '.glb',
    ];
    return supportedExtensions.any(
      (ext) => filePath.toLowerCase().endsWith(ext),
    );
  }

  /// Получить список поддерживаемых форматов
  List<String> getSupportedFormats() {
    return ['comics', 'boranko', 'collada', 'obj', 'gltf', 'glb'];
  }

  /// Получить информацию о возможностях платформы
  Future<Map<String, bool>> getPlatformCapabilities() async {
    try {
      // Проверяем различные возможности платформы
      final capabilities = <String, bool>{
        'ar_support': false,
        'vr_support': false,
        'dome_projection': false,
        'native_3d': false,
      };

      // Пытаемся инициализировать рендерер для проверки поддержки
      try {
        capabilities['native_3d'] = await initializeRenderer();
      } catch (e) {
        debugPrint('Native 3D not supported: $e');
      }

      // Проверяем AR поддержку
      try {
        capabilities['ar_support'] = await FlutterFreedomePlayerPlatform
            .instance
            .startARSession();
        if (capabilities['ar_support']!) {
          await FlutterFreedomePlayerPlatform.instance.stopARSession();
        }
      } catch (e) {
        debugPrint('AR not supported: $e');
      }

      // VR поддержка зависит от платформы
      capabilities['vr_support'] =
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

      // Купольная проекция доступна на всех платформах через HTTP
      capabilities['dome_projection'] = true;

      return capabilities;
    } catch (e) {
      debugPrint('Error checking platform capabilities: $e');
      return {
        'ar_support': false,
        'vr_support': false,
        'dome_projection': true,
        'native_3d': false,
      };
    }
  }

  /// Получить рекомендованную конфигурацию для формата
  PlayerConfig getRecommendedConfig(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        return PlayerConfig.defaultComics;
      case MediaFormat.boranko:
        return const PlayerConfig(
          enableDomeProjection: true,
          enableVR: true,
          backgroundColor: 0xFF000000,
        );
      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        return PlayerConfig.default3D;
      case MediaFormat.unknown:
        return const PlayerConfig();
    }
  }

  /// Создать MediaContent из файла
  static MediaContent createMediaContent({
    required String filePath,
    String? name,
    MediaFormat? format,
    PlaybackMode playbackMode = PlaybackMode.screen,
    Map<String, dynamic>? metadata,
    Duration? duration,
    List<String>? tags,
    String? description,
    String? author,
  }) {
    // Определяем формат если не указан
    format ??= _detectFormatFromPath(filePath);

    // Определяем имя если не указано
    name ??= _extractNameFromPath(filePath);

    return MediaContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      filePath: filePath,
      format: format,
      playbackMode: playbackMode,
      metadata: metadata,
      duration: duration,
      tags: tags,
      description: description,
      author: author,
      createdAt: DateTime.now(),
    );
  }

  /// Определить формат по пути к файлу
  static MediaFormat _detectFormatFromPath(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'comics':
        return MediaFormat.comics;
      case 'boranko':
        return MediaFormat.boranko;
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

  /// Извлечь имя из пути к файлу
  static String _extractNameFromPath(String filePath) {
    final fileName = filePath.split('/').last;
    final nameWithoutExtension = fileName.split('.').first;
    return nameWithoutExtension.replaceAll('_', ' ').replaceAll('-', ' ');
  }

  /// Логирование для отладки
  static void enableDebugLogging(bool enabled) {
    // Можно использовать для включения/выключения отладочных сообщений
    debugPrint(
      'FreeDome Player debug logging: ${enabled ? 'enabled' : 'disabled'}',
    );
  }
}
