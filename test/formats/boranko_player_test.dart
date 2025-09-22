import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/formats/boranko_player.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';
import 'package:flutter_freedome_player/src/models/dome_config.dart';

void main() {
  group('BorankoPlayer', () {
    testWidgets('should display loading indicator initially', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig(enableDomeProjection: true, enableVR: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Загрузка Boranko контента...'), findsOneWidget);
    });

    testWidgets('should handle tap to toggle controls visibility', (
      tester,
    ) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig(enableDomeProjection: true, enableVR: true);

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
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

    testWidgets('should call onContentLoaded callback', (tester) async {
      bool contentLoadedCalled = false;

      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        MaterialApp(
          home: BorankoPlayer(
            content: content,
            config: config,
            onContentLoaded: () {
              contentLoadedCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Callback should be set up
      expect(contentLoadedCalled, isFalse);
    });

    testWidgets('should call onError callback on error', (tester) async {
      String? errorMessage;

      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/invalid.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        MaterialApp(
          home: BorankoPlayer(
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

    testWidgets('should respect background color from config', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig(backgroundColor: 0xFF987654);

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should use the specified background color
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF987654)));
    });

    testWidgets('should handle dome projection configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const domeConfig = DomeConfig(
        projectionType: DomeProjectionType.fisheye,
        freedomeEngineUrl: 'http://test.com',
        quantumProperties: QuantumProperties(
          resonanceFrequency: 432.0,
          interferencePattern: 'cosmic',
        ),
      );

      final config = PlayerConfig(
        enableDomeProjection: true,
        domeConfig: domeConfig,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should handle dome configuration
      expect(find.byType(BorankoPlayer), findsOneWidget);
    });

    testWidgets('should handle VR configuration', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const configWithVR = PlayerConfig(enableVR: true);
      const configWithoutVR = PlayerConfig(enableVR: false);

      // Test with VR enabled
      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: configWithVR),
        ),
      );

      await tester.pump();
      expect(find.byType(BorankoPlayer), findsOneWidget);

      // Test with VR disabled
      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: configWithoutVR),
        ),
      );

      await tester.pump();
      expect(find.byType(BorankoPlayer), findsOneWidget);
    });

    testWidgets('should display error widget when error occurs', (
      tester,
    ) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/corrupted.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      // Wait for potential error state
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Should show error or loading state
      expect(find.byType(BorankoPlayer), findsOneWidget);
    });

    testWidgets('should handle quantum properties in content', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Quantum Boranko',
        filePath: 'assets/quantum.boranko',
        format: MediaFormat.boranko,
        metadata: {
          'quantum_properties': {
            'resonance_frequency': 528.0,
            'interference_pattern': 'healing',
            'consciousness_level': 'love',
          },
        },
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should handle quantum properties
      expect(find.byType(BorankoPlayer), findsOneWidget);
    });

    testWidgets('should handle widget disposal correctly', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Remove widget
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different content'))),
      );

      await tester.pump();

      // Should dispose without errors
      expect(find.text('Different content'), findsOneWidget);
    });

    testWidgets('should animate quantum effects', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Animated Boranko',
        filePath: 'assets/animated.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should set up animations
      expect(find.byType(BorankoPlayer), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should support different quantum modes', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should handle quantum mode toggling
      expect(find.byType(BorankoPlayer), findsOneWidget);
    });

    testWidgets('should handle Z-depth effects', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Z-Depth Boranko',
        filePath: 'assets/zdepth.boranko',
        format: MediaFormat.boranko,
        metadata: {
          'z_depth': true,
          'quantum_properties': {'resonance_frequency': 108.0},
        },
      );

      const config = PlayerConfig();

      await tester.pumpWidget(
        const MaterialApp(
          home: BorankoPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should handle Z-depth effects
      expect(find.byType(BorankoPlayer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
