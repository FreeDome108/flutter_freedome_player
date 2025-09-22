import 'package:flutter/material.dart';

import '../models/media_content.dart';
import '../models/player_config.dart';
import 'model_3d_player.dart';

/// Специализированный плеер для COLLADA файлов (.dae)
/// Наследует функциональность от Model3DPlayer с дополнительными возможностями для COLLADA
class ColladaPlayer extends StatelessWidget {
  final MediaContent content;
  final PlayerConfig config;
  final VoidCallback? onModelLoaded;
  final VoidCallback? onModelError;
  final Function(String)? onError;

  const ColladaPlayer({
    super.key,
    required this.content,
    required this.config,
    this.onModelLoaded,
    this.onModelError,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // COLLADA плеер использует тот же функционал что и общий 3D плеер
    // В будущем здесь могут быть добавлены специфичные для COLLADA функции
    return Model3DPlayer(
      content: content,
      config: config,
      onModelLoaded: onModelLoaded,
      onModelError: onModelError,
      onError: onError,
    );
  }
}
