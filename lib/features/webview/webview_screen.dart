import 'dart:async'; // Fixed capitalization

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'no_internet_page.dart'; // Added semicolon
import '../../config/app_config.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  StreamSubscription<InternetStatus>? _networkSubscription;

  bool _isOffline = false;
  bool _isLoading = true;
  bool _hasError = false;

  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _listenToNetwork();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _timeoutTimer?.cancel();
            _timeoutTimer = Timer(
              AppConfig.connectionTimeout,
              () {
                if (_isLoading && mounted) {
                  _showOfflinePage();
                }
              },
            );

            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) {
            _timeoutTimer?.cancel();
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = false;
              _isOffline = false;
            });
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
            if (_isMainFrameError(error)) {
              _showOfflinePage();
            }
          },
          onHttpError: (error) {
            debugPrint('HTTP error: ${error.response?.statusCode}');
            final status = error.response?.statusCode;
            if (status != null && status >= 500) {
              _showOfflinePage();
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            if ((uri.scheme == 'https' || uri.scheme == 'http') &&
                uri.host == AppConfig.allowedHost) {
              return NavigationDecision.navigate;
            }

            // TODO: Handle external links (WhatsApp, Intent URIs, etc.)
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.productionUrl));
  }

  bool _isMainFrameError(WebResourceError error) {
    return error.isForMainFrame ?? true;
  }

  void _listenToNetwork() {
    // Updated API call for internet_connection_checker_plus
    _networkSubscription =
        InternetConnection().onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isOffline = status == InternetStatus.disconnected;
        });
      }
    });
  }

  void _showOfflinePage() {
    _timeoutTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isOffline = true;
      _isLoading = false;
      _hasError = true;
    });
  }

  Future<void> _retry() async {
    if (!mounted) return;
    setState(() {
      _isOffline = false;
      _isLoading = true;
      _hasError = false;
    });

    final status = await InternetConnection().internetStatus;

    if (status == InternetStatus.disconnected) {
      if (!mounted) return;
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
      return;
    }

    await _controller.reload();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android back button
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppConfig.backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              if (!_isOffline)
                Positioned.fill(
                  child: WebViewWidget(controller: _controller),
                ),
                
              if (_isOffline)
                Positioned.fill(
                  child: OfflinePage(onRetry: _retry), // Assumed name from your import
                ),
                
              // Display a loading indicator when a page is loading
              if (_isLoading && !_isOffline)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
