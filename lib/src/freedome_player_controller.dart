import 'package:flutter/foundation.dart';
import 'models/media_content.dart';
import 'models/player_config.dart';
import 'services/media_loader_service.dart';
import 'services/dome_projection_service.dart';

/// Контроллер для FreeDome плеера
class FreeDomePlayerController extends ChangeNotifier {
  MediaContent? _currentContent;
  PlayerConfig _config = const PlayerConfig();
  bool _isLoading = false;
  bool _isPlaying = false;
  String? _error;

  final MediaLoaderService _mediaLoader = MediaLoaderService();
  final DomeProjectionService _domeService = DomeProjectionService();

  // Геттеры
  MediaContent? get currentContent => _currentContent;
  PlayerConfig get config => _config;
  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  String? get error => _error;
  bool get hasContent => _currentContent != null;

  /// Загрузить медиа контент
  Future<bool> loadContent(String filePath) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔵 [PLAYER_CONTROLLER] Loading content: $filePath');

      final content = await _mediaLoader.loadMediaContent(filePath);
      if (content == null) {
        _setError('Не удалось загрузить контент: $filePath');
        return false;
      }

      _currentContent = content;

      // Автоматически настраиваем конфигурацию плеера под формат
      _autoConfigureForFormat(content.format);

      debugPrint('🟢 [PLAYER_CONTROLLER] Content loaded: ${content.name}');

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка загрузки контента: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Загрузить контент из MediaContent объекта
  void loadMediaContent(MediaContent content) {
    _currentContent = content;
    _autoConfigureForFormat(content.format);
    _clearError();
    notifyListeners();
  }

  /// Обновить конфигурацию плеера
  void updateConfig(PlayerConfig config) {
    _config = config;
    notifyListeners();
  }

  /// Начать воспроизведение
  Future<void> play() async {
    if (_currentContent == null) return;

    try {
      _isPlaying = true;
      notifyListeners();

      // Если включена купольная проекция, отправляем контент в купол
      if (_config.enableDomeProjection && _config.domeConfig != null) {
        await _sendToDome();
      }

      debugPrint(
          '🟢 [PLAYER_CONTROLLER] Started playing: ${_currentContent!.name}');
    } catch (e) {
      _setError('Ошибка воспроизведения: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  /// Остановить воспроизведение
  void stop() {
    _isPlaying = false;
    notifyListeners();
    debugPrint('🔴 [PLAYER_CONTROLLER] Stopped playing');
  }

  /// Пауза воспроизведения
  void pause() {
    _isPlaying = false;
    notifyListeners();
    debugPrint('⏸️ [PLAYER_CONTROLLER] Paused playing');
  }

  /// Возобновить воспроизведение
  void resume() {
    _isPlaying = true;
    notifyListeners();
    debugPrint('▶️ [PLAYER_CONTROLLER] Resumed playing');
  }

  /// Переключить воспроизведение/паузу
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Очистить текущий контент
  void clearContent() {
    _currentContent = null;
    _isPlaying = false;
    _clearError();
    notifyListeners();
  }

  /// Переключить режим воспроизведения
  void switchPlaybackMode(PlaybackMode mode) {
    if (_currentContent == null) return;

    // Проверяем поддержку режима
    bool supported = false;
    switch (mode) {
      case PlaybackMode.screen:
        supported = true;
        break;
      case PlaybackMode.dome:
        supported = _currentContent!.supportsDomeProjection;
        break;
      case PlaybackMode.ar:
        supported = _currentContent!.supportsAR;
        break;
      case PlaybackMode.vr:
        supported = _currentContent!.supportsVR;
        break;
    }

    if (!supported) {
      _setError('Режим $mode не поддерживается для данного контента');
      return;
    }

    _currentContent = _currentContent!.copyWith(playbackMode: mode);

    // Обновляем конфигурацию плеера
    switch (mode) {
      case PlaybackMode.screen:
        _config = _config.copyWith(
          enableDomeProjection: false,
          enableAR: false,
          enableVR: false,
        );
        break;
      case PlaybackMode.dome:
        _config = _config.copyWith(
          enableDomeProjection: true,
          enableAR: false,
          enableVR: false,
        );
        break;
      case PlaybackMode.ar:
        _config = _config.copyWith(
          enableDomeProjection: false,
          enableAR: true,
          enableVR: false,
        );
        break;
      case PlaybackMode.vr:
        _config = _config.copyWith(
          enableDomeProjection: false,
          enableAR: false,
          enableVR: true,
        );
        break;
    }

    notifyListeners();
  }

  /// Получить доступные режимы воспроизведения для текущего контента
  List<PlaybackMode> getAvailablePlaybackModes() {
    if (_currentContent == null) return [PlaybackMode.screen];

    final modes = <PlaybackMode>[PlaybackMode.screen];

    if (_currentContent!.supportsDomeProjection) {
      modes.add(PlaybackMode.dome);
    }

    if (_currentContent!.supportsAR) {
      modes.add(PlaybackMode.ar);
    }

    if (_currentContent!.supportsVR) {
      modes.add(PlaybackMode.vr);
    }

    return modes;
  }

  /// Автоматически настроить конфигурацию под формат
  void _autoConfigureForFormat(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        _config = PlayerConfig.defaultComics;
        break;
      case MediaFormat.boranko:
        _config = _config.copyWith(
          enableDomeProjection: true,
          enableVR: true,
          backgroundColor: 0xFF000000,
        );
        break;
      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        _config = PlayerConfig.default3D;
        break;
      case MediaFormat.unknown:
        _config = const PlayerConfig();
        break;
    }
  }

  /// Отправить контент в купол
  Future<void> _sendToDome() async {
    if (_currentContent == null || _config.domeConfig == null) return;

    try {
      // Инициализируем подключение к куполу
      final connected = await _domeService.initialize(_config.domeConfig!);
      if (!connected) {
        _setError('Не удалось подключиться к FreeDome Engine');
        return;
      }

      // Отправляем контент
      final sent = await _domeService.sendModel(_currentContent!);
      if (!sent) {
        _setError('Не удалось отправить контент в купол');
        return;
      }

      debugPrint('🟢 [PLAYER_CONTROLLER] Content sent to dome successfully');
    } catch (e) {
      _setError('Ошибка отправки в купол: $e');
    }
  }

  /// Установить состояние загрузки
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Установить ошибку
  void _setError(String error) {
    _error = error;
    debugPrint('🔴 [PLAYER_CONTROLLER] Error: $error');
    notifyListeners();
  }

  /// Очистить ошибку
  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _domeService.disconnect();
    super.dispose();
  }
}
