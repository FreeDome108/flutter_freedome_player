# flutter_freedome_player

Flutter plugin for playing 3D/AR/VR content and various media formats including .comics, .boranko, collada and others. Supports both screen display and dome projections.

## Features

### Supported Formats
- **Comics** (.comics) - ZIP archives with images and metadata
- **Boranko** (.boranko) - Advanced 2D format with Z-depth for dome projection  
- **COLLADA** (.dae) - XML-based 3D model format
- **OBJ** (.obj) - Simple 3D model format
- **glTF** (.gltf) - Modern 3D transmission format
- **glTF Binary** (.glb) - Binary version of glTF

### Playback Modes
- **Screen** - Standard display on device screen
- **Dome** - FreeDome dome projection with quantum properties
- **AR** - Augmented Reality (for 3D models)
- **VR** - Virtual Reality (for 3D models and Boranko content)

### Advanced Features
- **Quantum Properties** - Spiritual resonance frequencies (108 Hz)
- **FreeDome Integration** - Direct connection to FreeDome Engine
- **OSC Protocol** - Real-time dome control
- **Z-Depth Effects** - Advanced 2D to 3D conversion for Boranko format
- **Chakra Frequencies** - Support for meditation and consciousness content

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_freedome_player: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:flutter_freedome_player/flutter_freedome_player.dart';

// Create a simple player widget
FreeDomePlayerWidget(
  filePath: 'assets/models/buddha.dae',
  showControls: true,
  autoPlay: true,
  onContentLoaded: () {
    print('Content loaded successfully!');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

### Advanced Usage with Controller

```dart
import 'package:flutter_freedome_player/flutter_freedome_player.dart';

class MyPlayerScreen extends StatefulWidget {
  @override
  _MyPlayerScreenState createState() => _MyPlayerScreenState();
}

class _MyPlayerScreenState extends State<MyPlayerScreen> {
  late FreeDomePlayerController controller;

  @override
  void initState() {
    super.initState();
    
    // Create controller with custom config
    final config = PlayerConfig(
      enableAR: true,
      enableDomeProjection: true,
      autoRotate: true,
      backgroundColor: 0xFF000000,
      domeConfig: DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        domeRadius: 5.0,
        freedomeEngineUrl: 'http://localhost:8080',
        quantumProperties: QuantumProperties(
          resonanceFrequency: 108.0,
          interferencePattern: 'spiritual',
        ),
      ),
    );
    
    controller = FreeDomePlayer().createController(config);
    loadContent();
  }

  Future<void> loadContent() async {
    final content = FreeDomePlayer.createMediaContent(
      filePath: 'assets/comics/mahabharata_ch1.comics',
      name: 'Mahabharata Chapter 1',
      format: MediaFormat.comics,
      description: 'First chapter of the great epic',
      author: 'Igor Baranko',
    );
    
    controller.loadMediaContent(content);
    await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FreeDomePlayerWidget(
        content: controller.currentContent,
        config: controller.config,
        showControls: true,
        onContentLoaded: () {
          // Content loaded callback
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### Comics Player

```dart
// Load and display comics
final comicsContent = FreeDomePlayer.createMediaContent(
  filePath: 'assets/comics/chapter1.comics',
  format: MediaFormat.comics,
);

FreeDomePlayerWidget(
  content: comicsContent,
  config: PlayerConfig.defaultComics,
  showControls: true,
)
```

### 3D Model Player

```dart
// Load and display 3D model
final modelContent = FreeDomePlayer.createMediaContent(
  filePath: 'assets/models/buddha.dae',
  format: MediaFormat.collada,
  playbackMode: PlaybackMode.ar, // Enable AR
);

FreeDomePlayerWidget(
  content: modelContent,
  config: PlayerConfig.default3D,
  showControls: true,
)
```

### Boranko Player with Dome Projection

```dart
// Load Boranko content for dome projection
final domeConfig = DomeConfig(
  projectionType: DomeProjectionType.fisheye,
  domeRadius: 5.0,
  freedomeEngineUrl: 'http://freedome-engine:8080',
  quantumProperties: QuantumProperties(
    resonanceFrequency: 108.0,
    consciousnessLevel: 'meditation',
  ),
);

final borankoContent = FreeDomePlayer.createMediaContent(
  filePath: 'assets/boranko/meditation.boranko',
  format: MediaFormat.boranko,
  playbackMode: PlaybackMode.dome,
);

FreeDomePlayerWidget(
  content: borankoContent,
  config: PlayerConfig.domeProjection(domeConfig),
  showControls: true,
)
```

## Configuration

### PlayerConfig

```dart
PlayerConfig(
  enableAR: true,              // Enable AR functionality
  enableVR: false,             // Enable VR functionality  
  enableDomeProjection: true,  // Enable dome projection
  autoRotate: true,            // Auto-rotate 3D models
  cameraControls: true,        // Enable camera controls
  backgroundColor: 0xFF2A2A2A, // Background color
  renderQuality: 1.0,          // Render quality (0.1 - 2.0)
  domeConfig: domeConfig,      // Dome configuration
)
```

### DomeConfig

```dart
DomeConfig(
  projectionType: DomeProjectionType.fisheye,
  domeRadius: 5.0,
  projectorCount: 1,
  edgeBlending: false,
  colorCorrection: true,
  freedomeEngineUrl: 'http://localhost:8080',
  oscPort: 8000,
  oscHost: 'localhost',
  quantumProperties: QuantumProperties(
    resonanceFrequency: 108.0,
    interferencePattern: 'spiritual',
    consciousnessLevel: 'meditation',
    quantumElements: 108,
    fractalDimension: 2.618,
  ),
)
```

## Platform Support

| Platform | Screen | AR | VR | Dome |
|----------|--------|----|----|------|
| Android  | ✅     | ✅ | ✅ | ✅   |
| iOS      | ✅     | ✅ | ✅ | ✅   |
| Web      | ✅     | ❌ | ❌ | ✅   |
| macOS    | ✅     | ❌ | ❌ | ✅   |
| Linux    | ✅     | ❌ | ❌ | ✅   |
| Windows  | ✅     | ❌ | ❌ | ✅   |

## FreeDome Integration

This plugin integrates with the FreeDome ecosystem:

- **FreeDome Engine** - Rust-based dome projection engine
- **FreeDome Sphere** - Flutter application for dome content
- **Quantum Calibration** - Advanced projection calibration
- **OSC Protocol** - Real-time dome control

### OSC Commands

```dart
// Send OSC commands to dome
await domeService.sendOSCCommand('/dome/radius', [5.0]);
await domeService.sendOSCCommand('/quantum/frequency', [108.0]);
await domeService.sendOSCCommand('/projection/mode', ['fisheye']);
```

## Dependencies

This plugin depends on:

- `flutter_3d_controller` - 3D rendering
- `model_viewer_plus` - Web 3D viewer
- `vector_math` - 3D mathematics
- `xml` - COLLADA parsing
- `archive` - Comics file handling
- `http` - FreeDome Engine communication
- `provider` - State management

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For support and questions, please open an issue on the GitHub repository.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.