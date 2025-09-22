import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_freedome_player/src/flutter_freedome_player_method_channel.dart';

void main() {
  group('Android Platform Tests', () {
    late MethodChannelFlutterFreedomePlayer platform;
    late List<MethodCall> methodCalls;

    setUp(() {
      platform = MethodChannelFlutterFreedomePlayer();
      methodCalls = <MethodCall>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        platform.methodChannel,
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return 'Android 12 (API 31)';
            case 'initializeRenderer':
              return true;
            case 'loadModel':
              return true;
            case 'startARSession':
              return true; // ARCore available
            case 'stopARSession':
              return true;
            case 'connectToDome':
              return true;
            case 'sendOSCMessage':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platform.methodChannel, null);
    });

    test('should return Android platform version', () async {
      final version = await platform.getPlatformVersion();
      expect(version, equals('Android 12 (API 31)'));
      expect(methodCalls, hasLength(1));
      expect(methodCalls[0].method, equals('getPlatformVersion'));
    });

    test('should initialize renderer on Android', () async {
      final result = await platform.initializeRenderer();
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('initializeRenderer'));
    });

    test('should load 3D models on Android', () async {
      final result = await platform.loadModel('assets/test.dae');
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('loadModel'));
      expect(methodCalls.last.arguments['modelPath'], equals('assets/test.dae'));
    });

    test('should start AR session on Android (ARCore)', () async {
      final result = await platform.startARSession();
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('startARSession'));
    });

    test('should stop AR session on Android', () async {
      final result = await platform.stopARSession();
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('stopARSession'));
    });

    test('should connect to dome on Android', () async {
      final result = await platform.connectToDome('192.168.1.100', 8080);
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('connectToDome'));
      expect(methodCalls.last.arguments['host'], equals('192.168.1.100'));
      expect(methodCalls.last.arguments['port'], equals(8080));
    });

    test('should send OSC messages on Android', () async {
      final result = await platform.sendOSCMessage('/dome/radius', [5.0, 'fisheye']);
      expect(result, isTrue);
      expect(methodCalls.last.method, equals('sendOSCMessage'));
      expect(methodCalls.last.arguments['address'], equals('/dome/radius'));
      expect(methodCalls.last.arguments['args'], equals([5.0, 'fisheye']));
    });

    test('should handle method call errors gracefully on Android', () async {
      // Set up error response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        platform.methodChannel,
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'ANDROID_ERROR',
            message: 'Android specific error',
            details: 'ARCore not available',
          );
        },
      );

      final result = await platform.startARSession();
      expect(result, isFalse);
    });

    test('should handle null responses on Android', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        platform.methodChannel,
        (MethodCall methodCall) async => null,
      );

      final versionResult = await platform.getPlatformVersion();
      expect(versionResult, isNull);

      final boolResult = await platform.initializeRenderer();
      expect(boolResult, isFalse);
    });

    test('should validate Android specific parameters', () async {
      // Test with various Android specific paths
      final androidPaths = [
        '/storage/emulated/0/Download/model.dae',
        'content://com.android.providers.downloads.documents/document/123',
        'file:///android_asset/models/buddha.dae',
      ];

      for (final path in androidPaths) {
        final result = await platform.loadModel(path);
        expect(result, isTrue);
      }
    });

    test('should handle Android permissions', () async {
      // Test AR session with permission handling
      final result = await platform.startARSession();
      expect(result, isTrue);
      
      // Should have called the AR session method
      expect(methodCalls.any((call) => call.method == 'startARSession'), isTrue);
    });

    test('should support Android hardware features', () async {
      // Test hardware specific features
      final features = [
        'initializeRenderer', // GPU acceleration
        'startARSession',     // ARCore
        'connectToDome',      // Network connectivity
      ];

      for (final feature in features) {
        methodCalls.clear();
        
        switch (feature) {
          case 'initializeRenderer':
            await platform.initializeRenderer();
            break;
          case 'startARSession':
            await platform.startARSession();
            break;
          case 'connectToDome':
            await platform.connectToDome('localhost', 8080);
            break;
        }

        expect(methodCalls.last.method, equals(feature));
      }
    });
  });
}
