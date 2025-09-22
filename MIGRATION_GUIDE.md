# Flutter FreeDome Player - Migration Guide

Этот документ описывает процесс миграции с отдельных библиотек на использование `flutter_freedome_player`.

## Обзор миграции

`flutter_freedome_player` объединяет функциональность следующих библиотек:
- `flutter_3d_controller` - 3D рендеринг
- `model_viewer_plus` - Web 3D просмотрщик  
- `ar_flutter_plugin` - AR функциональность
- `vector_math` - 3D математика
- Пользовательские решения для комиксов (.comics)
- Поддержка формата .boranko

## Миграция Samskara

### До миграции (старый код)

```yaml
# pubspec.yaml
dependencies:
  flutter_3d_controller: ^2.2.0
  model_viewer_plus: ^1.9.3
  ar_flutter_plugin: ^0.7.3
  vector_math: ^2.1.4
```

```dart
// lib/widgets/model_3d_viewer.dart
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../services/three_d_service.dart';
import '../services/zelim_converter_service.dart';

class Model3DViewer extends StatefulWidget {
  // ... старая реализация
  
  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: widget.modelPath,
      alt: widget.modelName,
      ar: widget.enableAR,
      autoRotate: true,
      cameraControls: true,
      // ...
    );
  }
}
```

### После миграции (новый код)

```yaml
# pubspec.yaml
dependencies:
  flutter_freedome_player:
    path: ../../../libsFreeDome/flutter_freedome_player
```

```dart
// lib/widgets/model_3d_viewer_new.dart
import 'package:flutter_freedome_player/flutter_freedome_player.dart';

class Model3DViewerNew extends StatefulWidget {
  // ... новая реализация
  
  @override
  Widget build(BuildContext context) {
    return FreeDomePlayerWidget(
      content: _controller.currentContent,
      config: _controller.config,
      showControls: true,
      autoPlay: false,
      onContentLoaded: widget.onModelLoaded,
      onError: (error) => widget.onModelError?.call(),
    );
  }
}
```

### Инициализация контроллера

```dart
// Новый подход с контроллером
Future<void> _initializePlayer() async {
  // Определяем формат модели
  MediaFormat format = MediaFormat.collada; // или другой формат
  
  // Создаем контент
  final content = FreeDomePlayer.createMediaContent(
    filePath: widget.modelPath,
    name: widget.modelName,
    format: format,
    playbackMode: widget.enableAR ? PlaybackMode.ar : PlaybackMode.screen,
  );

  // Создаем конфигурацию
  PlayerConfig config = PlayerConfig.default3D.copyWith(
    enableAR: widget.enableAR,
    enableDomeProjection: widget.enableZelim,
    autoRotate: true,
    cameraControls: true,
  );

  // Если включен ZELIM, добавляем купольную проекцию
  if (widget.enableZelim) {
    config = config.copyWith(
      domeConfig: DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        quantumProperties: QuantumProperties(
          resonanceFrequency: 108.0,
          interferencePattern: 'spiritual',
        ),
      ),
    );
  }

  // Создаем контроллер
  _controller = FreeDomePlayer().createController(config);
  _controller.loadMediaContent(content);
}
```

## Миграция Mahabharata

### До миграции (старый код)

```dart
// lib/core/services/comics_service.dart
class ComicsService {
  Future<Map<String, dynamic>?> readComicsFile(String filePath) async {
    // Пользовательская реализация чтения ZIP архивов
    final ByteData data = await rootBundle.load(filePath);
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    // ... много кода для обработки
  }
}

// lib/features/episode/widgets/comics_viewer.dart  
class ComicsViewer extends StatefulWidget {
  // Пользовательская реализация просмотра комиксов
  // ... много кода для управления страницами
}
```

### После миграции (новый код)

```dart
// lib/features/episode/widgets/comics_viewer_new.dart
import 'package:flutter_freedome_player/flutter_freedome_player.dart';

class ComicsViewerNew extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return FreeDomePlayerWidget(
      content: _controller.currentContent,
      config: _controller.config,
      showControls: true,
      onContentLoaded: () => _showSuccessMessage(),
      onError: (error) => _showErrorMessage(error),
    );
  }
}
```

### Инициализация комиксов

```dart
Future<void> _initializePlayer() async {
  // Создаем контент для комикса
  final content = FreeDomePlayer.createMediaContent(
    filePath: widget.comicsFilePath,
    name: widget.episodeTitle,
    format: MediaFormat.comics,
    description: 'Mahabharata Episode Comics',
    author: 'Igor Baranko & Alexey Chebykin',
  );

  // Используем конфигурацию для комиксов
  final config = PlayerConfig.defaultComics.copyWith(
    backgroundColor: 0xFF000000,
    renderQuality: 1.0,
  );

  _controller = FreeDomePlayer().createController(config);
  _controller.loadMediaContent(content);
}
```

## Основные изменения в API

### 1. Замена прямых вызовов библиотек на контроллер

**Старый подход:**
```dart
ModelViewer(
  src: modelPath,
  ar: enableAR,
  autoRotate: true,
)
```

**Новый подход:**
```dart
final controller = FreeDomePlayer().createController(config);
controller.loadContent(modelPath);

FreeDomePlayerWidget(
  content: controller.currentContent,
  config: controller.config,
)
```

### 2. Унифицированная конфигурация

**Старый подход:**
```dart
// Разные настройки в разных местах
ModelViewer(ar: true, autoRotate: true);
// + отдельные сервисы для ZELIM, купола и т.д.
```

**Новый подход:**
```dart
PlayerConfig(
  enableAR: true,
  enableDomeProjection: true,
  autoRotate: true,
  domeConfig: DomeConfig(
    projectionType: DomeProjectionType.fisheye,
    quantumProperties: QuantumProperties(...),
  ),
)
```

### 3. Обработка событий

**Старый подход:**
```dart
ModelViewer(
  onWebViewCreated: (controller) {
    // Обработка создания WebView
  },
)
```

**Новый подход:**
```dart
FreeDomePlayerWidget(
  onContentLoaded: () {
    // Контент загружен
  },
  onError: (error) {
    // Обработка ошибок
  },
  onPlaybackStarted: () {
    // Воспроизведение началось
  },
)
```

## Преимущества новой архитектуры

### 1. Унификация
- Один плеер для всех форматов
- Единый API для всех типов контента
- Консистентная обработка ошибок

### 2. Расширяемость
- Легко добавлять новые форматы
- Модульная архитектура
- Плагинная система

### 3. FreeDome интеграция
- Встроенная поддержка купольной проекции
- Квантовые свойства и резонансы
- OSC протокол для управления

### 4. Производительность
- Оптимизированная загрузка контента
- Кеширование и предзагрузка
- Адаптивное качество рендеринга

## Пошаговая миграция

### Шаг 1: Добавить зависимость

```yaml
dependencies:
  flutter_freedome_player:
    path: ../../../libsFreeDome/flutter_freedome_player
```

### Шаг 2: Удалить старые зависимости

```yaml
# Удалить эти строки:
# flutter_3d_controller: ^2.2.0
# model_viewer_plus: ^1.9.3
# ar_flutter_plugin: ^0.7.3
# vector_math: ^2.1.4
```

### Шаг 3: Обновить импорты

```dart
// Заменить:
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:flutter_3d_controller/flutter_3d_controller.dart';

// На:
import 'package:flutter_freedome_player/flutter_freedome_player.dart';
```

### Шаг 4: Создать новые виджеты

Создайте новые версии виджетов с суффиксом `_new.dart` и постепенно переводите на них функциональность.

### Шаг 5: Обновить навигацию

```dart
// Заменить вызовы старых виджетов на новые
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ARScreenNew(), // вместо ARScreen
  ),
);
```

### Шаг 6: Тестирование

Протестируйте все функции:
- Загрузка различных форматов
- AR режим
- Купольная проекция
- Обработка ошибок

## Обратная совместимость

Во время переходного периода можно использовать оба подхода параллельно:

```dart
// Условное использование в зависимости от флага
Widget build(BuildContext context) {
  if (useFreeDomePlayer) {
    return Model3DViewerNew(
      modelPath: modelPath,
      modelName: modelName,
    );
  } else {
    return Model3DViewer( // старая версия
      modelPath: modelPath,
      modelName: modelName,
    );
  }
}
```

## Часто задаваемые вопросы

### Q: Будут ли работать старые модели?
A: Да, все существующие модели (.dae, .obj, .gltf) полностью поддерживаются.

### Q: Сохранится ли функциональность AR?
A: Да, AR функциональность улучшена и теперь интегрирована с купольной проекцией.

### Q: Что происходит с ZELIM конвертацией?
A: ZELIM конвертация теперь встроена в плеер и происходит автоматически.

### Q: Как настроить квантовые свойства?
A: Используйте `QuantumProperties` в `DomeConfig` для настройки частот и резонансов.

## Поддержка

Если у вас возникли вопросы по миграции, создайте issue в репозитории или обратитесь к документации плагина.
