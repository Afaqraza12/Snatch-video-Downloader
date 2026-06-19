import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaPlayerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const MediaPlayerScreen({super.key, required this.filePath, required this.title});

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isAudio = false;

  @override
  void initState() {
    super.initState();
    _isAudio = widget.filePath.toLowerCase().endsWith('.mp3') || widget.filePath.toLowerCase().endsWith('.m4a');
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw Exception("File not found or was deleted.");
      }

      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio > 0 
            ? _videoPlayerController!.value.aspectRatio 
            : 1.0,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage.replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : _chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                ? _isAudio 
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.music_note, size: 100, color: Colors.grey),
                          Chewie(controller: _chewieController!),
                        ],
                      )
                    : Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
