import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_content.dart';
import '../models/player_config.dart';
import '../freedome_player_controller.dart';
import '../formats/comics_player.dart';
import '../formats/model_3d_player.dart';
import '../formats/boranko_player.dart';
import 'media_controls.dart';

/// Основной виджет FreeDome плеера
class FreeDomePlayerWidget extends StatefulWidget {
  final String? filePath;
  final MediaContent? content;
  final PlayerConfig? config;
  final VoidCallback? onContentLoaded;
  final VoidCallback? onPlaybackStarted;
  final VoidCallback? onPlaybackStopped;
  final Function(String)? onError;
  final bool showControls;
  final bool autoPlay;

  const FreeDomePlayerWidget({
    super.key,
    this.filePath,
    this.content,
    this.config,
    this.onContentLoaded,
    this.onPlaybackStarted,
    this.onPlaybackStopped,
    this.onError,
    this.showControls = true,
    this.autoPlay = false,
  });

  @override
  State<FreeDomePlayerWidget> createState() => _FreeDomePlayerWidgetState();
}

class _FreeDomePlayerWidgetState extends State<FreeDomePlayerWidget> {
  late FreeDomePlayerController _controller;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = FreeDomePlayerController();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(FreeDomePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Проверяем изменения в конфигурации
    if (widget.config != oldWidget.config && widget.config != null) {
      _controller.updateConfig(widget.config!);
    }

    // Проверяем изменения в контенте
    if (widget.content != oldWidget.content && widget.content != null) {
      _controller.loadMediaContent(widget.content!);
    }

    // Проверяем изменения в пути к файлу
    if (widget.filePath != oldWidget.filePath && widget.filePath != null) {
      _loadContentFromPath();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    // Устанавливаем конфигурацию
    if (widget.config != null) {
      _controller.updateConfig(widget.config!);
    }

    // Загружаем контент
    if (widget.content != null) {
      _controller.loadMediaContent(widget.content!);
      _controllerInitialized = true;

      if (widget.autoPlay) {
        await _controller.play();
      }

      widget.onContentLoaded?.call();
    } else if (widget.filePath != null) {
      await _loadContentFromPath();
    }

    // Настраиваем слушатели
    _controller.addListener(_onControllerChanged);
  }

  Future<void> _loadContentFromPath() async {
    final success = await _controller.loadContent(widget.filePath!);
    if (success) {
      _controllerInitialized = true;

      if (widget.autoPlay) {
        await _controller.play();
      }

      widget.onContentLoaded?.call();
    }
  }

  void _onControllerChanged() {
    if (_controller.error != null) {
      widget.onError?.call(_controller.error!);
    }

    if (_controller.isPlaying) {
      widget.onPlaybackStarted?.call();
    } else {
      widget.onPlaybackStopped?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FreeDomePlayerController>.value(
      value: _controller,
      child: Consumer<FreeDomePlayerController>(
        builder: (context, controller, child) {
          return Container(
            decoration: BoxDecoration(
              color: Color(controller.config.backgroundColor),
            ),
            child: Stack(
              children: [
                // Основной контент плеера
                _buildPlayerContent(controller),

                // Элементы управления
                if (widget.showControls && _controllerInitialized)
                  _buildMediaControls(controller),

                // Индикатор загрузки
                if (controller.isLoading) _buildLoadingIndicator(),

                // Сообщение об ошибке
                if (controller.error != null)
                  _buildErrorMessage(controller.error!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerContent(FreeDomePlayerController controller) {
    if (!controller.hasContent) {
      return _buildPlaceholder();
    }

    final content = controller.currentContent!;
    final config = controller.config;

    // Выбираем подходящий плеер в зависимости от формата
    switch (content.format) {
      case MediaFormat.comics:
        return ComicsPlayer(
          content: content,
          config: config,
          onPageChanged: () {
            // Уведомляем о смене страницы
          },
          onCompleted: () {
            controller.stop();
          },
          onError: (error) {
            widget.onError?.call(error);
          },
        );

      case MediaFormat.boranko:
        return BorankoPlayer(
          content: content,
          config: config,
          onContentLoaded: () {
            widget.onContentLoaded?.call();
          },
          onError: (error) {
            widget.onError?.call(error);
          },
        );

      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        return Model3DPlayer(
          content: content,
          config: config,
          onModelLoaded: () {
            widget.onContentLoaded?.call();
          },
          onModelError: () {
            widget.onError?.call('Ошибка загрузки 3D модели');
          },
          onError: (error) {
            widget.onError?.call(error);
          },
        );

      case MediaFormat.unknown:
        return _buildUnsupportedFormatMessage(content.format);
    }
  }

  Widget _buildMediaControls(FreeDomePlayerController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: MediaControls(
        controller: controller,
        onPlayPause: () {
          controller.togglePlayPause();
        },
        onStop: () {
          controller.stop();
        },
        onModeChanged: (mode) {
          controller.switchPlaybackMode(mode);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Загрузка контента...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка плеера',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _controller.clearContent();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Закрыть'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.filePath != null) {
                        _loadContentFromPath();
                      }
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'FreeDome Player',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Загрузите контент для воспроизведения',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedFormatMessage(MediaFormat format) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Неподдерживаемый формат',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Формат ${format.name} пока не поддерживается',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
