import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:math' as math;

import '../models/media_content.dart';
import '../models/player_config.dart';
import '../services/dome_projection_service.dart';

/// Плеер для 3D моделей (COLLADA, OBJ, glTF, glB)
class Model3DPlayer extends StatefulWidget {
  final MediaContent content;
  final PlayerConfig config;
  final VoidCallback? onModelLoaded;
  final VoidCallback? onModelError;
  final Function(String)? onError;

  const Model3DPlayer({
    super.key,
    required this.content,
    required this.config,
    this.onModelLoaded,
    this.onModelError,
    this.onError,
  });

  @override
  State<Model3DPlayer> createState() => _Model3DPlayerState();
}

class _Model3DPlayerState extends State<Model3DPlayer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  bool _showInfo = false;
  DomeProjectionService? _domeService;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.config.autoRotate) {
      _rotationController.repeat();
    }

    // Инициализируем купольную проекцию если включена
    if (widget.config.enableDomeProjection &&
        widget.config.domeConfig != null) {
      _domeService = DomeProjectionService();
      _initializeDomeProjection();
    }

    _initializeModel();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _domeService?.disconnect();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Проверяем доступность модели
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      widget.onModelLoaded?.call();
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки 3D модели: $e';
        _isLoading = false;
      });
      widget.onError?.call(_error!);
      widget.onModelError?.call();
    }
  }

  Future<void> _initializeDomeProjection() async {
    if (_domeService != null && widget.config.domeConfig != null) {
      try {
        await _domeService!.initialize(widget.config.domeConfig!);
        await _domeService!.sendModel(widget.content);
      } catch (e) {
        debugPrint('Error initializing dome projection: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(widget.config.backgroundColor),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          ),
        ),
        child: Stack(
          children: [
            // Основной 3D вид
            _buildMain3DView(),

            // Информационная панель
            if (_showInfo) _buildInfoPanel(),

            // Панель управления
            if (_showControls) _buildControlPanel(),

            // Индикатор загрузки
            if (_isLoading) _buildLoadingIndicator(),

            // Сообщение об ошибке
            if (_error != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildMain3DView() {
    debugPrint('🔵 [3D_PLAYER] Building main 3D view');

    // Если ошибка загрузки, показываем fallback
    if (_error != null) {
      debugPrint('🟡 [3D_PLAYER] Model error, using fallback animated scene');
      return _buildFallbackScene();
    }

    debugPrint('🟢 [3D_PLAYER] Creating ModelViewer with:');
    debugPrint('  - src: ${widget.content.filePath}');
    debugPrint('  - alt: ${widget.content.name}');
    debugPrint('  - AR enabled: ${widget.config.enableAR}');
    debugPrint('  - Auto rotate: ${widget.config.autoRotate}');
    debugPrint('  - Camera controls: ${widget.config.cameraControls}');

    // Используем model_viewer_plus для всех форматов
    return ModelViewer(
      src: widget.content.filePath,
      alt: widget.content.name,
      ar: widget.config.enableAR,
      autoRotate: widget.config.autoRotate,
      cameraControls: widget.config.cameraControls,
      backgroundColor: Color(widget.config.backgroundColor),
      loading: Loading.eager,
      reveal: Reveal.auto,
      onWebViewCreated: (controller) {
        debugPrint('🟢 [3D_PLAYER] ModelViewer WebView created successfully');
        setState(() {
          _isLoading = false;
        });
        widget.onModelLoaded?.call();
      },
    );
  }

  Widget _buildFallbackScene() {
    return Container(
      child: CustomPaint(
        painter: Animated3DScenePainter(
          modelName: widget.content.name,
          primaryColor: Colors.blue,
          animation: _rotationAnimation,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Загрузка 3D модели...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeModel,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final metadata = widget.content.metadata;

    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.content.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showInfo = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.content.description != null) ...[
              Text(
                widget.content.description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (metadata != null) ...[
              _buildInfoRow('Формат', widget.content.format.name.toUpperCase()),
              if (metadata['vertices'] != null)
                _buildInfoRow('Вершины', '${metadata['vertices']}'),
              if (metadata['triangles'] != null)
                _buildInfoRow('Треугольники', '${metadata['triangles']}'),
              if (metadata['materials_count'] != null)
                _buildInfoRow('Материалы', '${metadata['materials_count']}'),
              if (metadata['has_animations'] == true)
                _buildInfoRow('Анимации', 'Да'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Информация о модели
            IconButton(
              onPressed: () {
                setState(() {
                  _showInfo = !_showInfo;
                });
              },
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: 'Информация',
            ),

            // Автоповорот
            IconButton(
              onPressed: () {
                if (_rotationController.isAnimating) {
                  _rotationController.stop();
                } else {
                  _rotationController.repeat();
                }
              },
              icon: Icon(
                _rotationController.isAnimating
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              tooltip: 'Автоповорот',
            ),

            // AR режим (если поддерживается)
            if (widget.config.enableAR)
              IconButton(
                onPressed: () {
                  // TODO: Запустить AR режим
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('AR режим будет доступен в следующих версиях'),
                    ),
                  );
                },
                icon: const Icon(Icons.view_in_ar, color: Colors.white),
                tooltip: 'AR режим',
              ),

            // Купольная проекция (если включена)
            if (widget.config.enableDomeProjection)
              IconButton(
                onPressed: () {
                  _sendToDome();
                },
                icon: const Icon(Icons.panorama_fisheye, color: Colors.white),
                tooltip: 'Отправить в купол',
              ),

            // Сброс камеры
            IconButton(
              onPressed: () {
                // TODO: Сбросить позицию камеры
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Сбросить камеру',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendToDome() async {
    if (_domeService != null) {
      try {
        await _domeService!.sendModel(widget.content);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Модель отправлена в купол'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка отправки в купол: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Художник для анимированной 3D сцены fallback
class Animated3DScenePainter extends CustomPainter {
  final String modelName;
  final Color primaryColor;
  final Animation<double> animation;

  Animated3DScenePainter({
    required this.modelName,
    this.primaryColor = Colors.blue,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final time = animation.value;

    // Фон
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Анимированные частицы
    final particlePaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20.0) * 2 * math.pi + time;
      final radius = size.width * 0.3 + math.sin(time * 2 + i) * 20;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        3 + math.sin(time * 4 + i) * 2,
        particlePaint
          ..color =
              primaryColor.withOpacity(0.4 + math.sin(time * 2 + i) * 0.2),
      );
    }

    // Центральный элемент
    final centerPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 30 + math.sin(time * 4) * 5, centerPaint);

    // Текст модели
    final textPainter = TextPainter(
      text: TextSpan(
        text: modelName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 60),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
