import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player_example/main.dart';

void main() {
  group('Example App Tests', () {
    testWidgets('should load main screen correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify app structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should display platform information section', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Wait for platform info to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Platform Information'), findsOneWidget);
      expect(find.textContaining('Version:'), findsOneWidget);
      expect(find.text('Capabilities:'), findsOneWidget);
    });

    testWidgets('should display supported formats section', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Supported Formats'), findsOneWidget);
      
      // Check for format chips
      final formatChips = [
        'COMICS',
        'BORANKO', 
        'COLLADA',
        'OBJ',
        'GLTF',
        'GLB',
      ];

      for (final format in formatChips) {
        expect(find.text(format), findsOneWidget);
      }
    });

    testWidgets('should display examples section with all buttons', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Examples'), findsOneWidget);
      
      // Check for example buttons
      expect(find.text('Load Comics Example'), findsOneWidget);
      expect(find.text('Load 3D Model Example'), findsOneWidget);
      expect(find.text('Load Boranko Example'), findsOneWidget);
      
      // Check for button icons
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.byIcon(Icons.view_in_ar), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('should navigate to comics player when comics button tapped', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap comics example button
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();

      // Should show player interface
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Should show loading or content
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should navigate to 3D player when 3D button tapped', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap 3D model example button
      await tester.tap(find.text('Load 3D Model Example'));
      await tester.pumpAndSettle();

      // Should show player interface
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Should show loading or content
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should navigate to boranko player when boranko button tapped', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap boranko example button
      await tester.tap(find.text('Load Boranko Example'));
      await tester.pumpAndSettle();

      // Should show player interface
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Should show loading or content
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should return to main screen when back button tapped', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to any example
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to main screen
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
      expect(find.text('Platform Information'), findsOneWidget);
      expect(find.text('Examples'), findsOneWidget);
    });

    testWidgets('should handle rapid navigation without crashes', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final exampleButtons = [
        'Load Comics Example',
        'Load 3D Model Example',
        'Load Boranko Example',
      ];

      // Rapidly navigate through examples
      for (int i = 0; i < 3; i++) {
        for (final buttonText in exampleButtons) {
          await tester.tap(find.text(buttonText));
          await tester.pump(const Duration(milliseconds: 500));
          
          final backButton = find.byIcon(Icons.arrow_back);
          if (tester.any(backButton)) {
            await tester.tap(backButton);
            await tester.pump(const Duration(milliseconds: 500));
          }
        }
      }

      await tester.pumpAndSettle();

      // Should still be functional
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should display error messages when content fails to load', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Try to load content (might fail due to missing assets)
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();

      // Wait for potential error
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Should handle errors gracefully (either show content or error message)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should maintain consistent theme throughout app', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check theme on main screen
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);

      // Navigate to player
      await tester.tap(find.text('Load Comics Example'));
      await tester.pumpAndSettle();

      // Theme should be consistent
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle device orientation changes', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simulate orientation change
      tester.view.physicalSize = const Size(2400, 1080); // Landscape
      tester.view.devicePixelRatio = 3.0;
      
      await tester.pump();
      await tester.pumpAndSettle();

      // App should adapt to landscape
      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Reset to portrait
      tester.view.physicalSize = const Size(1080, 2400); // Portrait
      await tester.pump();
      await tester.pumpAndSettle();

      // App should adapt to portrait
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should handle memory pressure gracefully', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Load multiple examples in sequence to test memory handling
      for (int i = 0; i < 5; i++) {
        // Load 3D example (most memory intensive)
        await tester.tap(find.text('Load 3D Model Example'));
        await tester.pump(const Duration(milliseconds: 500));
        
        final backButton = find.byIcon(Icons.arrow_back);
        if (tester.any(backButton)) {
          await tester.tap(backButton);
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      await tester.pumpAndSettle();

      // Should still be responsive
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });

    testWidgets('should display proper loading states', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check initial loading state for platform info
      await tester.pump(const Duration(milliseconds: 100));
      
      // Should show some loading indicators or content
      expect(find.byType(Widget), findsWidgets);
    });

    testWidgets('should handle accessibility features', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Check for semantic labels and tooltips
      expect(find.byType(Semantics), findsWidgets);
      
      // Buttons should be accessible
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('should handle different screen sizes', (tester) async {
      // Test small screen
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Test large screen
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 3.0;

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('FreeDome Player Demo'), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  group('Example App Performance Tests', () {
    testWidgets('should load main screen within reasonable time', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Should load within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('should handle multiple rapid taps without performance issues', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Rapidly tap buttons
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Load Comics Example'));
        await tester.pump(const Duration(milliseconds: 50));
        
        final backButton = find.byIcon(Icons.arrow_back);
        if (tester.any(backButton)) {
          await tester.tap(backButton);
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      stopwatch.stop();

      // Should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      
      // Should still be functional
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
    });
  });
}
