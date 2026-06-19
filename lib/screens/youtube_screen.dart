import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/youtube_service.dart';
import '../widgets/url_input_card.dart';
import '../providers/shared_intent_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';

class YoutubeScreen extends ConsumerStatefulWidget {
  const YoutubeScreen({super.key});

  @override
  ConsumerState<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends ConsumerState<YoutubeScreen> {
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
    if (shared != null && shared.platform == 'YouTube') {
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
      final ytService = ref.read(youtubeServiceProvider);
      final video = await ytService.getVideoInfo(url);
      final manifest = await ytService.getManifest(video.id);
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      final settings = ref.read(settingsProvider);
      if (settings.defaultQuality != 'Ask Every Time') {
        _autoDownload(video, manifest, ytService, url, settings.defaultQuality);
      } else {
        _showQualitySelector(video, manifest, ytService, url);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      String errorMsg = e.toString();
      if (e is SocketException) {
        errorMsg = 'No internet connection.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMsg')),
      );
    }
  }

  void _autoDownload(Video video, StreamManifest manifest, YoutubeService ytService, String originalUrl, String quality) {
    try {
      StreamInfo? selectedStream;
      bool isVideo = true;

      final muxedStreams = manifest.muxed.sortByVideoQuality();
      final videoOnlyStreams = manifest.videoOnly.sortByVideoQuality();
      final audioStreams = manifest.audioOnly.sortByBitrate();

      // Combine muxed + videoOnly for best quality selection
      final allVideoStreams = <VideoStreamInfo>[...muxedStreams, ...videoOnlyStreams];

      if (quality == 'Audio Only') {
        selectedStream = audioStreams.isNotEmpty ? audioStreams.last : null;
        isVideo = false;
      } else if (quality == 'Highest Available') {
        // Pick the highest quality from all streams (videoOnly will have 1080p+)
        selectedStream = allVideoStreams.isNotEmpty ? allVideoStreams.last : null;
      } else if (quality == '1080p') {
        try {
          selectedStream = allVideoStreams.firstWhere((s) => s.videoQuality.name.contains('1080'));
        } catch (_) {
          selectedStream = allVideoStreams.isNotEmpty ? allVideoStreams.last : null;
        }
      } else if (quality == '720p') {
        try {
          selectedStream = allVideoStreams.firstWhere((s) => s.videoQuality.name.contains('720'));
        } catch (_) {
          selectedStream = allVideoStreams.isNotEmpty ? allVideoStreams.last : null;
        }
      }

      if (selectedStream != null) {
        ytService.downloadVideo(
          ref: ref,
          url: originalUrl,
          video: video,
          streamInfo: selectedStream,
          isVideo: isVideo,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Requested quality not found. Falling back to quality selector.')),
          );
          _showQualitySelector(video, manifest, ytService, originalUrl);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auto-download error: ${e.toString()}')),
        );
      }
    }
  }

  void _showQualitySelector(Video video, StreamManifest manifest, YoutubeService ytService, String originalUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final muxedStreams = manifest.muxed.sortByVideoQuality();
        final videoOnlyStreams = manifest.videoOnly.sortByVideoQuality();
        final audioStreams = manifest.audioOnly.sortByBitrate();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Select Quality', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            if (videoOnlyStreams.isNotEmpty) ...[
              const Text('HD Video (Video Only — no audio)', style: TextStyle(fontWeight: FontWeight.bold)),
              ...videoOnlyStreams.map((stream) => ListTile(
                title: Text('${stream.videoQuality.name} (${stream.container.name})'),
                subtitle: Text('${(stream.size.totalMegaBytes).toStringAsFixed(1)} MB'),
                onTap: () {
                  Navigator.pop(context);
                  ytService.downloadVideo(
                    ref: ref,
                    url: originalUrl,
                    video: video,
                    streamInfo: stream,
                    isVideo: true,
                  );
                },
              )),
              const Divider(),
            ],
            const Text('Video + Audio', style: TextStyle(fontWeight: FontWeight.bold)),
            ...muxedStreams.map((stream) => ListTile(
              title: Text('${stream.videoQuality.name} (${stream.container.name})'),
              subtitle: Text('${(stream.size.totalMegaBytes).toStringAsFixed(1)} MB'),
              onTap: () {
                Navigator.pop(context);
                ytService.downloadVideo(
                  ref: ref,
                  url: originalUrl,
                  video: video,
                  streamInfo: stream,
                  isVideo: true,
                );
              },
            )),
            const Divider(),
            const Text('Audio Only', style: TextStyle(fontWeight: FontWeight.bold)),
            ...audioStreams.map((stream) => ListTile(
              title: Text('Audio (${stream.container.name})'),
              subtitle: Text('${(stream.size.totalMegaBytes).toStringAsFixed(1)} MB'),
              onTap: () {
                Navigator.pop(context);
                ytService.downloadVideo(
                  ref: ref,
                  url: originalUrl,
                  video: video,
                  streamInfo: stream,
                  isVideo: false,
                );
              },
            )),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SharedUrlState?>(sharedUrlProvider, (previous, next) {
      if (next != null && next.platform == 'YouTube') {
        _urlController.text = next.url;
        _handleDownload();
        Future.microtask(() => ref.read(sharedUrlProvider.notifier).clear());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader'),
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
              hintText: 'Paste YouTube URL here...',
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
