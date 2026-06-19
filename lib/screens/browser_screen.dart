import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../providers/shared_intent_provider.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  double _progress = 0.0;
  bool _hasBeenVisible = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;

    params = AndroidWebViewControllerCreationParams();

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _urlController.text = url;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    // Enable the Android WebView to use the hybrid composition mode
    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // Don't load request here, wait for first visibility
  }

  void _checkVisibility() {
    final currentIndex = ref.watch(tabIndexProvider);
    if (!_hasBeenVisible && currentIndex == 3) {
      _hasBeenVisible = true;
      _controller.loadRequest(Uri.parse('https://www.google.com'));
    }
  }

  void _loadUrl() {
    String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      if (!url.startsWith('http')) {
        url = 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
      }
      try {
        _controller.loadRequest(Uri.parse(url));
        FocusScope.of(context).unfocus();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: $e')),
        );
      }
    }
  }

  void _triggerDownload() async {
    final currentUrl = await _controller.currentUrl();
    if (currentUrl != null) {
      if (currentUrl.contains('youtube.com') || currentUrl.contains('youtu.be')) {
        ref.read(sharedUrlProvider.notifier).setSharedUrl(currentUrl);
        ref.read(tabIndexProvider.notifier).setIndex(0);
      } else if (currentUrl.contains('tiktok.com')) {
        ref.read(sharedUrlProvider.notifier).setSharedUrl(currentUrl);
        ref.read(tabIndexProvider.notifier).setIndex(1);
      } else if (currentUrl.contains('instagram.com')) {
        ref.read(sharedUrlProvider.notifier).setSharedUrl(currentUrl);
        ref.read(tabIndexProvider.notifier).setIndex(2);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please navigate to a supported platform (YouTube, TikTok, Instagram)')),
        );
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkVisibility();

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Search or enter URL',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _loadUrl(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () async {
              if (await _controller.canGoForward()) {
                _controller.goForward();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: _hasBeenVisible
          ? WebViewWidget(controller: _controller)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _triggerDownload,
        icon: const Icon(Icons.download),
        label: const Text('Download Page'),
      ),
    );
  }
}
