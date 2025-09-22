import 'package:flutter/material.dart';
import '../freedome_player_controller.dart';
import '../models/media_content.dart';

/// Виджет элементов управления медиа плеером
class MediaControls extends StatefulWidget {
  final FreeDomePlayerController controller;
  final VoidCallback? onPlayPause;
  final VoidCallback? onStop;
  final Function(PlaybackMode)? onModeChanged;
  final bool showModeSelector;
  final bool compact;

  const MediaControls({
    super.key,
    required this.controller,
    this.onPlayPause,
    this.onStop,
    this.onModeChanged,
    this.showModeSelector = true,
    this.compact = false,
  });

  @override
  State<MediaControls> createState() => _MediaControlsState();
}

class _MediaControlsState extends State<MediaControls>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });

    if (_isVisible) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.hasContent) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(widget.compact ? 8.0 : 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Основные элементы управления
              _buildMainControls(),

              // Селектор режима воспроизведения
              if (widget.showModeSelector && !widget.compact)
                _buildModeSelector(),

              // Информация о контенте
              if (!widget.compact) _buildContentInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainControls() {
    final content = widget.controller.currentContent!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Кнопка остановки
          IconButton(
            onPressed: widget.onStop,
            icon: const Icon(Icons.stop, color: Colors.white),
            tooltip: 'Остановить',
          ),

          // Кнопка воспроизведения/паузы
          IconButton(
            onPressed: widget.onPlayPause,
            icon: Icon(
              widget.controller.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 40,
            ),
            tooltip: widget.controller.isPlaying ? 'Пауза' : 'Воспроизвести',
          ),

          // Информация о контенте (компактный режим)
          if (widget.compact)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    content.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    content.format.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Кнопка настроек
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'Настройки',
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Информация'),
                  ],
                ),
              ),
              if (content.supportsDomeProjection)
                const PopupMenuItem(
                  value: 'dome',
                  child: Row(
                    children: [
                      Icon(Icons.panorama_fisheye),
                      SizedBox(width: 8),
                      Text('Отправить в купол'),
                    ],
                  ),
                ),
              if (content.supportsAR)
                const PopupMenuItem(
                  value: 'ar',
                  child: Row(
                    children: [
                      Icon(Icons.view_in_ar),
                      SizedBox(width: 8),
                      Text('AR режим'),
                    ],
                  ),
                ),
              if (content.supportsVR)
                const PopupMenuItem(
                  value: 'vr',
                  child: Row(
                    children: [
                      Icon(Icons.vrpano),
                      SizedBox(width: 8),
                      Text('VR режим'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final availableModes = widget.controller.getAvailablePlaybackModes();
    final currentMode = widget.controller.currentContent!.playbackMode;

    if (availableModes.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: availableModes.map((mode) {
          final isSelected = mode == currentMode;

          return GestureDetector(
            onTap: () {
              widget.onModeChanged?.call(mode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.6)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getModeIcon(mode),
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getModeLabel(mode),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentInfo() {
    final content = widget.controller.currentContent!;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Иконка формата
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFormatColor(content.format).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFormatIcon(content.format),
              color: _getFormatColor(content.format),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Информация о контенте
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (content.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    content.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '${content.format.name.toUpperCase()} • ${_getModeLabel(content.playbackMode)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Статус воспроизведения
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.controller.isPlaying
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.controller.isPlaying ? 'Воспроизводится' : 'Остановлено',
              style: TextStyle(
                color: widget.controller.isPlaying ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'info':
        _showContentInfo();
        break;
      case 'dome':
        widget.onModeChanged?.call(PlaybackMode.dome);
        break;
      case 'ar':
        widget.onModeChanged?.call(PlaybackMode.ar);
        break;
      case 'vr':
        widget.onModeChanged?.call(PlaybackMode.vr);
        break;
    }
  }

  void _showContentInfo() {
    final content = widget.controller.currentContent!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Формат', content.format.name.toUpperCase()),
            _buildInfoRow('Режим', _getModeLabel(content.playbackMode)),
            if (content.description != null)
              _buildInfoRow('Описание', content.description!),
            if (content.author != null) _buildInfoRow('Автор', content.author!),
            if (content.duration != null)
              _buildInfoRow('Длительность', _formatDuration(content.duration!)),
            if (content.metadata != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Дополнительная информация:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...content.metadata!.entries.take(5).map((entry) => _buildInfoRow(
                    entry.key,
                    entry.value.toString(),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon(PlaybackMode mode) {
    switch (mode) {
      case PlaybackMode.screen:
        return Icons.smartphone;
      case PlaybackMode.dome:
        return Icons.panorama_fisheye;
      case PlaybackMode.ar:
        return Icons.view_in_ar;
      case PlaybackMode.vr:
        return Icons.vrpano;
    }
  }

  String _getModeLabel(PlaybackMode mode) {
    switch (mode) {
      case PlaybackMode.screen:
        return 'Экран';
      case PlaybackMode.dome:
        return 'Купол';
      case PlaybackMode.ar:
        return 'AR';
      case PlaybackMode.vr:
        return 'VR';
    }
  }

  IconData _getFormatIcon(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        return Icons.menu_book;
      case MediaFormat.boranko:
        return Icons.psychology;
      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        return Icons.view_in_ar;
      case MediaFormat.unknown:
        return Icons.help_outline;
    }
  }

  Color _getFormatColor(MediaFormat format) {
    switch (format) {
      case MediaFormat.comics:
        return Colors.orange;
      case MediaFormat.boranko:
        return Colors.purple;
      case MediaFormat.collada:
      case MediaFormat.obj:
      case MediaFormat.gltf:
      case MediaFormat.glb:
        return Colors.blue;
      case MediaFormat.unknown:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
