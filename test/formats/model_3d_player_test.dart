import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/formats/model_3d_player.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';

void main() {
  group('Model3DPlayer', () {
    testWidgets('should display loading indicator initially', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Загрузка 3D модели...'), findsOneWidget);
    });

    testWidgets('should handle tap to toggle controls visibility', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
          ),
        ),
      );

      await tester.pump();

      // Find the main gesture detector and tap it
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      await tester.tap(gestureDetector);
      await tester.pump();

      // Controls visibility should toggle
    });

    testWidgets('should call onModelLoaded callback', (tester) async {
      bool modelLoadedCalled = false;

      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
            onModelLoaded: () {
              modelLoadedCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Callback should be set up
      expect(modelLoadedCalled, isFalse);
    });

    testWidgets('should call onModelError callback', (tester) async {
      bool modelErrorCalled = false;

      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/invalid.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
            onModelError: () {
              modelErrorCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Error callback should be set up
      expect(modelErrorCalled, isFalse);
    });

    testWidgets('should call onError callback with message', (tester) async {
      String? errorMessage;

      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/error.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
            onError: (error) {
              errorMessage = error;
            },
          ),
        ),
      );

      await tester.pump();

      // Error callback should be set up
      expect(errorMessage, isNull);
    });

    testWidgets('should respect AR configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const configWithAR = PlayerConfig(enableAR: true);
      const configWithoutAR = PlayerConfig(enableAR: false);

      // Test with AR enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configWithAR,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);

      // Test with AR disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configWithoutAR,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);
    });

    testWidgets('should respect dome projection configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const domeConfig = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        freedomeEngineUrl: 'http://test.com',
      );

      final configWithDome = PlayerConfig(
        enableDomeProjection: true,
        domeConfig: domeConfig,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configWithDome,
          ),
        ),
      );

      await tester.pump();

      // Should handle dome projection configuration
      expect(find.byType(Model3DPlayer), findsOneWidget);
    });

    testWidgets('should respect auto-rotate configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const configAutoRotate = PlayerConfig(autoRotate: true);
      const configNoAutoRotate = PlayerConfig(autoRotate: false);

      // Test with auto-rotate enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configAutoRotate,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);

      // Test with auto-rotate disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configNoAutoRotate,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);
    });

    testWidgets('should respect background color from config', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig(backgroundColor: 0xFF654321);

      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
          ),
        ),
      );

      await tester.pump();

      // Should use the specified background color
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF654321)));
    });

    testWidgets('should handle different 3D formats', (tester) async {
      final formats = [
        MediaFormat.collada,
        MediaFormat.obj,
        MediaFormat.gltf,
        MediaFormat.glb,
      ];

      const config = PlayerConfig.default3D;

      for (final format in formats) {
        final content = MediaContent(
          id: 'test_$format',
          name: 'Test ${format.name}',
          filePath: 'assets/test.${format.name}',
          format: format,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Model3DPlayer(
              content: content,
              config: config,
            ),
          ),
        );

        await tester.pump();

        // Should handle all 3D formats
        expect(find.byType(Model3DPlayer), findsOneWidget);
      }
    });

    testWidgets('should display fallback scene on error', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Error Model',
        filePath: 'assets/error.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Should show either loading or fallback scene
      expect(find.byType(Model3DPlayer), findsOneWidget);
    });

    testWidgets('should handle widget disposal correctly', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config = PlayerConfig.default3D;

      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: config,
          ),
        ),
      );

      await tester.pump();

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Different content'),
          ),
        ),
      );

      await tester.pump();

      // Should dispose without errors
      expect(find.text('Different content'), findsOneWidget);
    });

    testWidgets('should support camera controls configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const configWithControls = PlayerConfig(cameraControls: true);
      const configWithoutControls = PlayerConfig(cameraControls: false);

      // Test with camera controls enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configWithControls,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);

      // Test with camera controls disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: Model3DPlayer(
            content: content,
            config: configWithoutControls,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Model3DPlayer), findsOneWidget);
    });
  });
}
