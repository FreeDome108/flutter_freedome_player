import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'test/models/media_content_test.dart' as media_content_test;
import 'test/models/player_config_test.dart' as player_config_test;
import 'test/models/dome_config_test.dart' as dome_config_test;
import 'test/services/format_detector_service_test.dart'
    as format_detector_test;
import 'test/services/dome_projection_service_test.dart'
    as dome_projection_test;
import 'test/freedome_player_controller_test.dart' as controller_test;
import 'test/freedome_player_api_test.dart' as api_test;
import 'test/widgets/freedome_player_widget_test.dart' as widget_test;
import 'test/formats/comics_player_test.dart' as comics_test;
import 'test/formats/model_3d_player_test.dart' as model_3d_test;
import 'test/formats/boranko_player_test.dart' as boranko_test;
import 'test/platform/android_platform_test.dart' as android_test;
import 'test/platform/ios_platform_test.dart' as ios_test;
import 'test/platform/web_platform_test.dart' as web_test;

/// Comprehensive test runner for FreeDome Player
///
/// Run with: dart test_runner.dart
/// Or: flutter test test_runner.dart
void main() {
  group('🧪 FreeDome Player - Complete Test Suite', () {
    group('📊 Models Tests', () {
      media_content_test.main();
      player_config_test.main();
      dome_config_test.main();
    });

    group('⚙️ Services Tests', () {
      format_detector_test.main();
      dome_projection_test.main();
    });

    group('🎮 Controller Tests', () {
      controller_test.main();
      api_test.main();
    });

    group('🎨 Widget Tests', () {
      widget_test.main();
    });

    group('🎭 Format Player Tests', () {
      comics_test.main();
      model_3d_test.main();
      boranko_test.main();
    });

    group('🌐 Platform Tests', () {
      android_test.main();
      ios_test.main();
      web_test.main();
    });
  });
}
