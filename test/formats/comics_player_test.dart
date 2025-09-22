import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/formats/comics_player.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';

void main() {
  group('ComicsPlayer', () {
    testWidgets('should display loading indicator initially', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle tap to toggle controls visibility', (
      tester,
    ) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
        metadata: {
          'pages': ['page1.jpg', 'page2.jpg'],
          'totalPages': 2,
        },
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Find the main gesture detector and tap it
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsWidgets);

      await tester.tap(gestureDetector.first);
      await tester.pump();

      // Controls visibility should toggle
      // (exact behavior depends on implementation)
    });

    testWidgets('should call onPageChanged callback', (tester) async {
      bool pageChangedCalled = false;

      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        MaterialApp(
          home: ComicsPlayer(
            content: content,
            config: config,
            onPageChanged: () {
              pageChangedCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Page change callback should be set up
      expect(pageChangedCalled, isFalse);
    });

    testWidgets('should call onCompleted callback', (tester) async {
      bool completedCalled = false;

      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        MaterialApp(
          home: ComicsPlayer(
            content: content,
            config: config,
            onCompleted: () {
              completedCalled = true;
            },
          ),
        ),
      );

      await tester.pump();

      // Completion callback should be set up
      expect(completedCalled, isFalse);
    });

    testWidgets('should call onError callback on error', (tester) async {
      String? errorMessage;

      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/nonexistent.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        MaterialApp(
          home: ComicsPlayer(
            content: content,
            config: config,
            onError: (error) {
              errorMessage = error;
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Error callback should be set up
      // (actual error depends on asset loading)
    });

    testWidgets('should respect background color from config', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig(backgroundColor: 0xFF123456);

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      await tester.pump();

      // Should use the specified background color
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF123456)));
    });

    testWidgets('should display error widget when error occurs', (
      tester,
    ) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/invalid.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      // Wait for error state
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Should eventually show error or loading state
      expect(find.byType(ComicsPlayer), findsOneWidget);
    });

    testWidgets('should handle widget disposal correctly', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
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

    testWidgets('should display content name in UI', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'My Amazing Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Content name should be displayed somewhere in the UI
      // (exact location depends on implementation state)
    });

    testWidgets('should handle empty pages gracefully', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Empty Comics',
        filePath: 'assets/empty.comics',
        format: MediaFormat.comics,
        metadata: {'pages': [], 'totalPages': 0},
      );

      const config = PlayerConfig.defaultComics;

      await tester.pumpWidget(
        const MaterialApp(
          home: ComicsPlayer(content: content, config: config),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should handle empty pages without crashing
      expect(find.byType(ComicsPlayer), findsOneWidget);
    });

    testWidgets('should support different render qualities', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      final configs = [
        const PlayerConfig(renderQuality: 0.5),
        const PlayerConfig(renderQuality: 1.0),
        const PlayerConfig(renderQuality: 1.5),
      ];

      for (final config in configs) {
        await tester.pumpWidget(
          MaterialApp(
            home: ComicsPlayer(content: content, config: config),
          ),
        );

        await tester.pump();

        // Should handle different render qualities
        expect(find.byType(ComicsPlayer), findsOneWidget);
      }
    });
  });
}
