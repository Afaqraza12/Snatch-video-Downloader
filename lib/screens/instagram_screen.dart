import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/instagram_service.dart';
import '../widgets/url_input_card.dart';
import '../providers/shared_intent_provider.dart';
import 'settings_screen.dart';

class InstagramScreen extends ConsumerStatefulWidget {
  const InstagramScreen({super.key});

  @override
  ConsumerState<InstagramScreen> createState() => _InstagramScreenState();
}

class _InstagramScreenState extends ConsumerState<InstagramScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSharedUrl();
    });
  }

  void _checkSharedUrl() {
    final shared = ref.read(sharedUrlProvider);
    if (shared != null && shared.platform == 'Instagram') {
      _urlController.text = shared.url;
      _handleDownload();
      ref.read(sharedUrlProvider.notifier).clear();
    }
  }

  void _handleDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    if (Uri.tryParse(url)?.isAbsolute != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL format. Please paste a valid link.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final instaService = ref.read(instagramServiceProvider);
      await instaService.downloadInstagram(ref, url);
      
      if (!mounted) return;
      _urlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download started')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SharedUrlState?>(sharedUrlProvider, (previous, next) {
      if (next != null && next.platform == 'Instagram') {
        _urlController.text = next.url;
        _handleDownload();
        Future.microtask(() => ref.read(sharedUrlProvider.notifier).clear());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram Downloader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            UrlInputCard(
              controller: _urlController,
              hintText: 'Paste Instagram URL here...',
              onDownload: _handleDownload,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
