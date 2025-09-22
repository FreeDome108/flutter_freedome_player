import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Utilities for testing FreeDome Player components
class TestUtils {
  /// Setup mock WebView platform for testing
  static void setupMockWebView() {
    WebViewPlatform.instance = MockWebViewPlatform();
  }

  /// Wrap widget with Material theme for testing
  static Widget wrapWithMaterial(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  /// Wrap widget with Material theme and custom config
  static Widget wrapWithMaterialAndTheme(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.dark(),
      home: Scaffold(body: child),
    );
  }

  /// Create a test MediaContent
  static const testComicsContent = MediaContent(
    id: 'test_comics',
    name: 'Test Comics',
    filePath: 'assets/test.comics',
    format: MediaFormat.comics,
  );

  static const testModelContent = MediaContent(
    id: 'test_model',
    name: 'Test Model',
    filePath: 'assets/test.dae',
    format: MediaFormat.collada,
  );

  static const testBorankoContent = MediaContent(
    id: 'test_boranko',
    name: 'Test Boranko',
    filePath: 'assets/test.boranko',
    format: MediaFormat.boranko,
  );
}

/// Mock WebView platform for testing
class MockWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return MockPlatformWebViewController();
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return MockPlatformWebViewWidget();
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return MockPlatformNavigationDelegate();
  }

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) {
    return MockPlatformWebViewCookieManager();
  }
}

/// Mock WebView controller for testing
class MockPlatformWebViewController extends PlatformWebViewController {
  MockPlatformWebViewController()
    : super.implementation(const PlatformWebViewControllerCreationParams());

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    // Mock implementation
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    // Mock implementation
  }

  @override
  Future<String?> currentUrl() async => 'mock://test.com';

  @override
  Future<bool> canGoBack() async => false;

  @override
  Future<bool> canGoForward() async => false;

  @override
  Future<void> goBack() async {
    // Mock implementation
  }

  @override
  Future<void> goForward() async {
    // Mock implementation
  }

  @override
  Future<void> reload() async {
    // Mock implementation
  }

  @override
  Future<void> clearCache() async {
    // Mock implementation
  }

  @override
  Future<void> clearLocalStorage() async {
    // Mock implementation
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    // Mock implementation
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    // Mock implementation
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    return 'mock_result';
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    // Mock implementation
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    // Mock implementation
  }

  @override
  Future<void> setUserAgent(String? userAgent) async {
    // Mock implementation
  }

  @override
  Future<void> enableZoom(bool enabled) async {
    // Mock implementation
  }

  @override
  Future<void> setTextZoom(int textZoom) async {
    // Mock implementation
  }
}

/// Mock WebView widget for testing
class MockPlatformWebViewWidget extends PlatformWebViewWidget {
  MockPlatformWebViewWidget()
    : super.implementation(
        const PlatformWebViewWidgetCreationParams(
          key: null,
          controller: MockPlatformWebViewController(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: const Center(child: Text('Mock WebView')),
    );
  }
}

/// Mock navigation delegate for testing
class MockPlatformNavigationDelegate extends PlatformNavigationDelegate {
  MockPlatformNavigationDelegate()
    : super.implementation(const PlatformNavigationDelegateCreationParams());

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {
    // Mock implementation
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    // Mock implementation
  }

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {
    // Mock implementation
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    // Mock implementation
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    // Mock implementation
  }

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {
    // Mock implementation
  }

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {
    // Mock implementation
  }
}

/// Mock cookie manager for testing
class MockPlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  MockPlatformWebViewCookieManager()
    : super.implementation(const PlatformWebViewCookieManagerCreationParams());

  @override
  Future<void> clearCookies() async {
    // Mock implementation
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) async {
    // Mock implementation
  }
}
