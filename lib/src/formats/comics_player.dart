import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

import '../models/media_content.dart';
import '../models/player_config.dart';

/// Плеер для комиксов (.comics формат)
class ComicsPlayer extends StatefulWidget {
  final MediaContent content;
  final PlayerConfig config;
  final VoidCallback? onPageChanged;
  final VoidCallback? onCompleted;
  final Function(String)? onError;

  const ComicsPlayer({
    super.key,
    required this.content,
    required this.config,
    this.onPageChanged,
    this.onCompleted,
    this.onError,
  });

  @override
  State<ComicsPlayer> createState() => _ComicsPlayerState();
}

class _ComicsPlayerState extends State<ComicsPlayer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<String> _pages = [];
  Map<String, dynamic>? _metadata;
  int _currentPage = 0;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  Map<String, Uint8List> _pageImages = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _loadComics();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadComics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Загружаем метаданные из MediaContent
      _metadata = widget.content.metadata;

      // Загружаем страницы
      _pages = await _getComicsPages();

      if (_pages.isEmpty) {
        // Если страницы не найдены, создаем демо-страницы
        _pages = _createDemoPages();
      }

      // Предзагружаем первые несколько страниц
      await _preloadPages(0, 3);

      setState(() {
        _isLoading = false;
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки комикса: $e';
        _isLoading = false;
      });
      widget.onError?.call(_error!);
    }
  }

  Future<List<String>> _getComicsPages() async {
    try {
      // Читаем файл как байты из assets
      final ByteData data = await rootBundle.load(widget.content.filePath);
      final Uint8List bytes = data.buffer.asUint8List();

      // Распаковываем ZIP архив
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      // Ищем изображения в архиве
      final List<String> pages = [];
      for (final file in archive) {
        if (file.isFile && _isImageFile(file.name)) {
          pages.add(file.name);

          // Сохраняем изображение в кеше
          _pageImages[file.name] = Uint8List.fromList(file.content);
        }
      }

      // Сортируем страницы по имени
      pages.sort();

      return pages;
    } catch (e) {
      debugPrint('Ошибка получения страниц комикса: $e');
      return [];
    }
  }

  Future<void> _preloadPages(int start, int count) async {
    for (int i = start; i < start + count && i < _pages.length; i++) {
      final pageName = _pages[i];
      if (!_pageImages.containsKey(pageName)) {
        try {
          final imageData = await _getPageImage(pageName);
          if (imageData != null) {
            _pageImages[pageName] = imageData;
          }
        } catch (e) {
          debugPrint('Ошибка предзагрузки страницы $pageName: $e');
        }
      }
    }
  }

  Future<Uint8List?> _getPageImage(String pageName) async {
    try {
      // Если уже есть в кеше
      if (_pageImages.containsKey(pageName)) {
        return _pageImages[pageName];
      }

      // Читаем из архива
      final ByteData data = await rootBundle.load(widget.content.filePath);
      final Uint8List bytes = data.buffer.asUint8List();
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.name == pageName && file.isFile) {
          final imageData = Uint8List.fromList(file.content);
          _pageImages[pageName] = imageData;
          return imageData;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Ошибка получения изображения страницы: $e');
      return null;
    }
  }

  List<String> _createDemoPages() {
    // Создаем демо-страницы для тестирования
    return [
      'assets/images/demo_page1.jpg',
      'assets/images/demo_page2.jpg',
      'assets/images/demo_page3.jpg',
      'assets/images/demo_page4.jpg',
      'assets/images/demo_page5.jpg',
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return _buildComicsViewer();
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color(widget.config.backgroundColor),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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
              onPressed: _loadComics,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComicsViewer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(widget.config.backgroundColor),
        ),
        child: Stack(
          children: [
            // Основной просмотрщик страниц
            _buildPageViewer(),

            // Элементы управления
            if (_showControls) _buildControls(),

            // Информация о странице
            if (_showControls) _buildPageInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewer() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });

          // Предзагружаем следующие страницы
          _preloadPages(index + 1, 3);

          widget.onPageChanged?.call();

          // Проверяем завершение
          if (index == _pages.length - 1) {
            widget.onCompleted?.call();
          }
        },
        itemBuilder: (context, index) {
          return _buildPage(index);
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    final pageName = _pages[index];
    final imageData = _pageImages[pageName];

    if (imageData != null) {
      return InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Image.memory(
            imageData,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPageError(pageName);
            },
          ),
        ),
      );
    } else {
      return _buildPagePlaceholder(pageName);
    }
  }

  Widget _buildPageError(String pageName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки страницы\n$pageName',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPagePlaceholder(String pageName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Загрузка страницы...',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: const Icon(Icons.skip_previous, color: Colors.white),
            ),
            Expanded(
              child: Slider(
                value: _currentPage.toDouble(),
                min: 0,
                max: (_pages.length - 1).toDouble(),
                divisions: _pages.length - 1,
                onChanged: (value) {
                  final page = value.round();
                  _goToPage(page);
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
            ),
            IconButton(
              onPressed: _currentPage < _pages.length - 1 ? _nextPage : null,
              icon: const Icon(Icons.skip_next, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageInfo() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.content.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_currentPage + 1} / ${_pages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _pages.length) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isImageFile(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
}
