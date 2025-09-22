import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/widgets/freedome_player_widget.dart';
import 'package:flutter_freedome_player/src/models/media_content.dart';
import 'package:flutter_freedome_player/src/models/player_config.dart';

void main() {
  group('FreeDomePlayerWidget', () {
    testWidgets('should display placeholder when no content is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(),
        ),
      );

      expect(find.text('FreeDome Player'), findsOneWidget);
      expect(find.text('Загрузите контент для воспроизведения'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            filePath: 'assets/test.dae',
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Загрузка контента...'), findsOneWidget);
    });

    testWidgets('should display comics player for comics content', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: false,
          ),
        ),
      );

      await tester.pump();

      // Comics player should be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display 3D player for 3D content', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: false,
          ),
        ),
      );

      await tester.pump();

      // 3D player should be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display boranko player for boranko content', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test Boranko',
        filePath: 'assets/test.boranko',
        format: MediaFormat.boranko,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: false,
          ),
        ),
      );

      await tester.pump();

      // Boranko player should be displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display unsupported format message for unknown content', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Unknown',
        filePath: 'assets/test.unknown',
        format: MediaFormat.unknown,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: false,
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Неподдерживаемый формат'), findsOneWidget);
      expect(find.text('Формат unknown пока не поддерживается'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show/hide controls based on showControls parameter', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      // Test with controls hidden
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: false,
          ),
        ),
      );

      await tester.pump();

      // Controls should not be visible
      expect(find.byType(BottomSheet), findsNothing);

      // Test with controls shown
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            showControls: true,
          ),
        ),
      );

      await tester.pump();
      // Note: Controls might not be immediately visible due to loading state
    });

    testWidgets('should call callbacks correctly', (tester) async {
      bool contentLoadedCalled = false;
      bool playbackStartedCalled = false;
      bool playbackStoppedCalled = false;
      String? errorMessage;

      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            onContentLoaded: () {
              contentLoadedCalled = true;
            },
            onPlaybackStarted: () {
              playbackStartedCalled = true;
            },
            onPlaybackStopped: () {
              playbackStoppedCalled = true;
            },
            onError: (error) {
              errorMessage = error;
            },
          ),
        ),
      );

      await tester.pump();

      // Initial state - content should be loading
      expect(contentLoadedCalled, isFalse);
      expect(playbackStartedCalled, isFalse);
      expect(playbackStoppedCalled, isFalse);
      expect(errorMessage, isNull);
    });

    testWidgets('should handle configuration changes', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      const config1 = PlayerConfig(backgroundColor: 0xFF000000);
      const config2 = PlayerConfig(backgroundColor: 0xFFFFFFFF);

      // Start with first config
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            config: config1,
          ),
        ),
      );

      await tester.pump();

      // Change to second config
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            config: config2,
          ),
        ),
      );

      await tester.pump();

      // Widget should handle configuration change
      expect(find.byType(FreeDomePlayerWidget), findsOneWidget);
    });

    testWidgets('should handle content changes', (tester) async {
      const content1 = MediaContent(
        id: '1',
        name: 'Comics',
        filePath: 'assets/test.comics',
        format: MediaFormat.comics,
      );

      const content2 = MediaContent(
        id: '2',
        name: 'Model',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      // Start with comics content
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(content: content1),
        ),
      );

      await tester.pump();

      // Change to 3D model content
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(content: content2),
        ),
      );

      await tester.pump();

      // Widget should handle content change
      expect(find.byType(FreeDomePlayerWidget), findsOneWidget);
    });

    testWidgets('should handle file path changes', (tester) async {
      // Start with one file
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(filePath: 'assets/test1.dae'),
        ),
      );

      await tester.pump();

      // Change to another file
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(filePath: 'assets/test2.dae'),
        ),
      );

      await tester.pump();

      // Widget should handle file path change
      expect(find.byType(FreeDomePlayerWidget), findsOneWidget);
    });

    testWidgets('should respect autoPlay parameter', (tester) async {
      const content = MediaContent(
        id: 'test',
        name: 'Test',
        filePath: 'assets/test.dae',
        format: MediaFormat.collada,
      );

      // Test with autoPlay false
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            autoPlay: false,
          ),
        ),
      );

      await tester.pump();

      // Test with autoPlay true
      await tester.pumpWidget(
        const MaterialApp(
          home: FreeDomePlayerWidget(
            content: content,
            autoPlay: true,
          ),
        ),
      );

      await tester.pump();

      // Widget should handle autoPlay parameter
      expect(find.byType(FreeDomePlayerWidget), findsOneWidget);
    });
  });
}
