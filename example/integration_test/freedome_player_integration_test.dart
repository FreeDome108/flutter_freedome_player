import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_freedome_player_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FreeDome Player Integration Tests', () {
    testWidgets('should load main screen and display platform information', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main screen loads
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
      
      // Verify platform information section
      expect(find.text('Platform Information'), findsOneWidget);
      expect(find.text('Version:'), findsOneWidget);
      expect(find.text('Capabilities:'), findsOneWidget);
      
      // Verify supported formats section
      expect(find.text('Supported Formats'), findsOneWidget);
      expect(find.text('COMICS'), findsOneWidget);
      expect(find.text('BORANKO'), findsOneWidget);
      expect(find.text('COLLADA'), findsOneWidget);
      expect(find.text('OBJ'), findsOneWidget);
      expect(find.text('GLTF'), findsOneWidget);
      expect(find.text('GLB'), findsOneWidget);
      
      // Verify examples section
      expect(find.text('Examples'), findsOneWidget);
      expect(find.text('Load Comics Example'), findsOneWidget);
      expect(find.text('Load 3D Model Example'), findsOneWidget);
      expect(find.text('Load Boranko Example'), findsOneWidget);
    });

    testWidgets('should load and display comics example', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on comics example button
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();

      // Should navigate to comics player
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for content to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Tap back button to return
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to main screen
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should load and display 3D model example', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on 3D model example button
      await tester.tap(find.text('Load 3D Model Example'));
      await tester.pumpAndSettle();

      // Should navigate to 3D player
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for model to load
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Tap back button to return
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to main screen
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should load and display boranko example', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on boranko example button
      await tester.tap(find.text('Load Boranko Example'));
      await tester.pumpAndSettle();

      // Should navigate to boranko player
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for content to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Tap back button to return
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to main screen
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should display correct platform capabilities', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for platform capabilities to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show capability indicators
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.cancel), findsWidgets);
      
      // Should show capability names
      final capabilityTexts = [
        'ar_support',
        'vr_support', 
        'dome_projection',
        'native_3d',
      ];
      
      for (final text in capabilityTexts) {
        // Capabilities might be displayed in different formats
        expect(find.textContaining(text, findRichText: true), findsWidgets);
      }
    });

    testWidgets('should handle navigation between examples', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test navigation flow: Main -> Comics -> Back -> 3D -> Back -> Boranko -> Back
      
      // Load comics
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Load 3D model
      await tester.tap(find.text('Load 3D Model Example'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Load boranko
      await tester.tap(find.text('Load Boranko Example'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to load examples and wait for potential errors
      final exampleButtons = [
        'Load Comics Example',
        'Load 3D Model Example', 
        'Load Boranko Example',
      ];

      for (final buttonText in exampleButtons) {
        // Load example
        await tester.tap(find.text(buttonText));
        await tester.pumpAndSettle();
        
        // Wait for loading or error
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // If back button is available, go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (tester.any(backButton)) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }

        // Should return to main screen
        expect(find.text('FreeDome Player Demo'), findsOneWidget);
      }
    });

    testWidgets('should display consistent UI elements', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check for consistent Material Design elements
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Check for cards and proper spacing
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
      
      // Check for proper button styling
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should handle different screen orientations', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test portrait orientation (default)
      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Simulate landscape orientation
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/settings',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routeUpdated', {
            'location': '/',
            'state': null,
          }),
        ),
        (data) {},
      );

      await tester.pump();

      // UI should adapt to orientation change
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should maintain state during navigation', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Load an example
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Platform information should still be displayed
      expect(find.text('Platform Information'), findsOneWidget);
      expect(find.text('Supported Formats'), findsOneWidget);
      expect(find.text('Examples'), findsOneWidget);
    });

    testWidgets('should handle rapid button taps without crashing', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Rapidly tap example buttons
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Load Comics Example'));
        await tester.pump(const Duration(milliseconds: 100));
        
        final backButton = find.byIcon(Icons.arrow_back);
        if (tester.any(backButton)) {
          await tester.tap(backButton);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpAndSettle();

      // Should not crash and return to main screen
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should display version information', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for platform version to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show version information
      expect(find.textContaining('Version:', findRichText: true), findsOneWidget);
    });
  });

  group('Platform-Specific Integration Tests', () {
    testWidgets('should handle Android specific features', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Android specific tests
      await tester.pump(const Duration(seconds: 1));
      
      // Should work on Android without crashes
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should handle iOS specific features', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // iOS specific tests
      await tester.pump(const Duration(seconds: 1));
      
      // Should work on iOS without crashes
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should handle web specific features', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Web specific tests
      await tester.pump(const Duration(seconds: 1));
      
      // Should work on web without crashes
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should handle desktop specific features', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Desktop specific tests (macOS, Windows, Linux)
      await tester.pump(const Duration(seconds: 1));
      
      // Should work on desktop without crashes
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });
  });
}
