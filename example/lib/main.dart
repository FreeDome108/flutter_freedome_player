import 'package:flutter/material.dart';
import 'package:flutter_freedome_player/flutter_freedome_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeDome Player Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FreeDome Player Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FreeDomePlayer _player = FreeDomePlayer();
  String _platformVersion = 'Unknown';
  Map<String, bool> _capabilities = {};
  FreeDomePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    Map<String, bool> capabilities;

    try {
      platformVersion =
          await _player.getPlatformVersion() ?? 'Unknown platform version';
      capabilities = await _player.getPlatformCapabilities();
    } catch (e) {
      platformVersion = 'Failed to get platform version: $e';
      capabilities = {};
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _capabilities = capabilities;
    });
  }

  void _loadComicsExample() {
    final content = FreeDomePlayer.createMediaContent(
      filePath: 'assets/comics/example.comics',
      name: 'Example Comics',
      format: MediaFormat.comics,
      description: 'Пример комикса для демонстрации',
    );

    setState(() {
      _controller = _player.createController();
      _controller!.loadMediaContent(content);
    });
  }

  void _load3DExample() {
    final content = FreeDomePlayer.createMediaContent(
      filePath: 'assets/models/example.dae',
      name: 'Example 3D Model',
      format: MediaFormat.collada,
      description: 'Пример 3D модели для демонстрации',
    );

    setState(() {
      _controller = _player.createController();
      _controller!.loadMediaContent(content);
    });
  }

  void _loadBorankoExample() {
    final content = FreeDomePlayer.createMediaContent(
      filePath: 'assets/boranko/example.boranko',
      name: 'Example Boranko',
      format: MediaFormat.boranko,
      description: 'Пример Boranko контента для демонстрации',
      playbackMode: PlaybackMode.dome,
    );

    setState(() {
      _controller = _player.createController();
      _controller!.loadMediaContent(content);
    });
  }

  void _clearContent() {
    setState(() {
      _controller?.clearContent();
      _controller = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _controller != null ? _buildPlayer() : _buildMainMenu(),
    );
  }

  Widget _buildMainMenu() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о платформе
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Platform Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Version: $_platformVersion'),
                  const SizedBox(height: 8),
                  Text(
                    'Capabilities:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ..._capabilities.entries.map(
                    (entry) => Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check_circle : Icons.cancel,
                          color: entry.value ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('${entry.key}: ${entry.value}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Поддерживаемые форматы
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported Formats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _player
                        .getSupportedFormats()
                        .map(
                          (format) => Chip(label: Text(format.toUpperCase())),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Примеры контента
          Text('Examples', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          // Кнопки примеров
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _loadComicsExample,
                icon: const Icon(Icons.menu_book),
                label: const Text('Load Comics Example'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _load3DExample,
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Load 3D Model Example'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadBorankoExample,
                icon: const Icon(Icons.psychology),
                label: const Text('Load Boranko Example'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    return Stack(
      children: [
        // Основной плеер
        FreeDomePlayerWidget(
          content: _controller!.currentContent,
          config: _controller!.config,
          showControls: true,
          autoPlay: false,
          onContentLoaded: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Контент загружен успешно!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),

        // Кнопка "Назад"
        Positioned(
          top: 40,
          left: 16,
          child: FloatingActionButton(
            heroTag: "back_button",
            mini: true,
            onPressed: _clearContent,
            backgroundColor: Colors.black.withOpacity(0.7),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
