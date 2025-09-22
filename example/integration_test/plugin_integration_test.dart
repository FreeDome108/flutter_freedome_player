// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host platform. For more information about Flutter integration tests,
// visit https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_freedome_player_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the FreeDome Player demo app loads
      expect(find.text('FreeDome Player Demo'), findsOneWidget);
      
      // Verify platform information is displayed
      expect(find.text('Platform Information'), findsOneWidget);
      
      // Verify examples section is displayed
      expect(find.text('Examples'), findsOneWidget);
    });
  });
}