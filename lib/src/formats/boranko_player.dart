import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media_content.dart';
import '../models/player_config.dart';
import '../services/dome_projection_service.dart';

/// Плеер для Boranko формата (.boranko)
class BorankoPlayer extends StatefulWidget {
  final MediaContent content;
  final PlayerConfig config;
  final VoidCallback? onContentLoaded;
  final Function(String)? onError;

  const BorankoPlayer({
    super.key,
    required this.content,
    required this.config,
    this.onContentLoaded,
    this.onError,
  });

  @override
  State<BorankoPlayer> createState() => _BorankoPlayerState();
}

class _BorankoPlayerState extends State<BorankoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Map<String, dynamic>? _borankoData;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  DomeProjectionService? _domeService;
  bool _quantumModeEnabled = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    // Инициализируем купольную проекцию если включена
    if (widget.config.enableDomeProjection &&
        widget.config.domeConfig != null) {
      _domeService = DomeProjectionService();
      _initializeDomeProjection();
    }

    _loadBorankoContent();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _domeService?.disconnect();
    super.dispose();
  }

  Future<void> _loadBorankoContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      String jsonContent;
      if (widget.content.filePath.startsWith('assets/')) {
        jsonContent = await rootBundle.loadString(widget.content.filePath);
      } else {
        final file = File(widget.content.filePath);
        if (!await file.exists()) {
          throw Exception('Файл не найден: ${widget.content.filePath}');
        }
        jsonContent = await file.readAsString();
      }

      _borankoData = json.decode(jsonContent);

      // Проверяем формат
      if (_borankoData!['format'] != 'boranko') {
        throw Exception('Неверный формат файла');
      }

      // Запускаем анимации
      _animationController.repeat(reverse: true);

      // Включаем квантовый режим если есть квантовые свойства
      final quantumProps = _borankoData!['quantum_properties'];
      if (quantumProps != null) {
        _quantumModeEnabled = true;
      }

      setState(() {
        _isLoading = false;
      });

      widget.onContentLoaded?.call();

      debugPrint('🟢 [BORANKO_PLAYER] Content loaded: ${widget.content.name}');
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки Boranko контента: $e';
        _isLoading = false;
      });
      widget.onError?.call(_error!);
    }
  }

  Future<void> _initializeDomeProjection() async {
    if (_domeService != null && widget.config.domeConfig != null) {
      try {
        await _domeService!.initialize(widget.config.domeConfig!);
        await _domeService!.sendModel(widget.content);

        // Включаем квантовый режим для купольной проекции
        await _domeService!.setQuantumMode(true);
      } catch (e) {
        debugPrint('Error initializing dome projection: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(widget.config.backgroundColor),
          gradient: _quantumModeEnabled
              ? _buildQuantumGradient()
              : _buildDefaultGradient(),
        ),
        child: Stack(
          children: [
            // Основной контент
            _buildBorankoContent(),

            // Z-Depth эффекты
            if (_quantumModeEnabled) _buildZDepthEffects(),

            // Элементы управления
            if (_showControls) _buildControls(),

            // Информационная панель
            if (_showControls) _buildInfoPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color(widget.config.backgroundColor),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 16),
            Text(
              'Загрузка Boranko контента...',
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

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color(widget.config.backgroundColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
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
              onPressed: _loadBorankoContent,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorankoContent() {
    if (_borankoData == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1, // Медленное вращение
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(0.8),
                      Colors.blue.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.content.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZDepthEffects() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ZDepthEffectsPainter(
            animation: _rotationAnimation.value,
            quantumProperties: _borankoData!['quantum_properties'],
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildControls() {
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
            // Квантовый режим
            IconButton(
              onPressed: () {
                setState(() {
                  _quantumModeEnabled = !_quantumModeEnabled;
                });

                if (_domeService != null) {
                  _domeService!.setQuantumMode(_quantumModeEnabled);
                }
              },
              icon: Icon(
                _quantumModeEnabled
                    ? Icons.psychology
                    : Icons.psychology_outlined,
                color: _quantumModeEnabled ? Colors.purple : Colors.white,
              ),
              tooltip: 'Квантовый режим',
            ),

            // Пауза/воспроизведение анимации
            IconButton(
              onPressed: () {
                if (_animationController.isAnimating) {
                  _animationController.stop();
                } else {
                  _animationController.repeat(reverse: true);
                }
              },
              icon: Icon(
                _animationController.isAnimating
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              tooltip: 'Пауза/Воспроизведение',
            ),

            // Купольная проекция
            if (widget.config.enableDomeProjection)
              IconButton(
                onPressed: () {
                  _sendToDome();
                },
                icon: const Icon(Icons.panorama_fisheye, color: Colors.white),
                tooltip: 'Отправить в купол',
              ),

            // VR режим
            if (widget.config.enableVR)
              IconButton(
                onPressed: () {
                  // TODO: Запустить VR режим
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('VR режим будет доступен в следующих версиях'),
                    ),
                  );
                },
                icon: const Icon(Icons.vrpano, color: Colors.white),
                tooltip: 'VR режим',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    if (_borankoData == null) return const SizedBox.shrink();

    final metadata = _borankoData!['metadata'];
    final quantumProps = _borankoData!['quantum_properties'];

    return Positioned(
      top: 40,
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
            Text(
              widget.content.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (metadata != null) ...[
              _buildInfoRow('Версия', '${_borankoData!['version']}'),
              if (metadata['description'] != null)
                _buildInfoRow('Описание', metadata['description']),
              if (metadata['author'] != null)
                _buildInfoRow('Автор', metadata['author']),
            ],
            if (quantumProps != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Квантовые свойства:',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildInfoRow('Частота резонанса',
                  '${quantumProps['resonance_frequency']} Hz'),
              _buildInfoRow('Паттерн интерференции',
                  quantumProps['interference_pattern']),
              _buildInfoRow(
                  'Уровень сознания', quantumProps['consciousness_level']),
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _buildQuantumGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A0033),
        Color(0xFF330066),
        Color(0xFF000033),
      ],
    );
  }

  LinearGradient _buildDefaultGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A1A1A),
        Color(0xFF2A2A2A),
      ],
    );
  }

  Future<void> _sendToDome() async {
    if (_domeService != null) {
      try {
        await _domeService!.sendModel(widget.content);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Boranko контент отправлен в купол'),
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

/// Художник для Z-Depth эффектов
class ZDepthEffectsPainter extends CustomPainter {
  final double animation;
  final Map<String, dynamic>? quantumProperties;

  ZDepthEffectsPainter({
    required this.animation,
    this.quantumProperties,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (quantumProperties == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Рисуем концентрические круги с Z-depth эффектом
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 50.0 + (animation * 20);
      final opacity = (1.0 - (i / 5.0)) * 0.5;

      paint.color = Colors.purple.withOpacity(opacity);

      canvas.drawCircle(center, radius, paint);
    }

    // Рисуем спиральные эффекты
    final spiralPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    for (double t = 0; t < 4 * math.pi; t += 0.1) {
      final r = t * 10 + animation * 5;
      final x = center.dx + r * math.cos(t + animation);
      final y = center.dy + r * math.sin(t + animation);

      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, spiralPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
