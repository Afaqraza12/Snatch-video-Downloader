import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../providers/download_provider.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  final Map<String, CancelToken> _cancelTokens = {};

  Future<void> startDownload({
    required WidgetRef ref,
    required String url,
    required String title,
    required String platform,
    required bool isVideo,
    String thumbnailUrl = '',
    String originalUrl = '',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final task = DownloadTask(
      id: id,
      title: title,
      platform: platform,
      thumbnailUrl: thumbnailUrl,
      originalUrl: originalUrl.isEmpty ? url : originalUrl,
    );

    ref.read(downloadProvider.notifier).addDownload(task);

    try {
      final tempDir = await getTemporaryDirectory();
      final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_');
      final ext = isVideo ? '.mp4' : '.mp3';
      final fileName = '${cleanTitle}_$id$ext';
      final tempPath = '${tempDir.path}/$fileName';

      final cancelToken = CancelToken();
      _cancelTokens[id] = cancelToken;

      await _dio.download(
        url,
        tempPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            ref.read(downloadProvider.notifier).updateProgress(id, progress);
          }
        },
      );

      _cancelTokens.remove(id);

      String finalPath = tempPath;

      try {
        Directory? directory;
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            directory = Directory('${downloadsDir.path}/Snatch');
          }
        } else {
          directory = Directory('/storage/emulated/0/Download/Snatch');
        }

        if (directory != null && !await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        if (directory != null) {
          finalPath = '${directory.path}/$fileName';
          await File(tempPath).copy(finalPath);
        }

        if (isVideo && (Platform.isIOS || Platform.isAndroid)) {
          final hasAccess = await Gal.hasAccess(toAlbum: true);
          if (!hasAccess) {
            await Gal.requestAccess(toAlbum: true);
          }
          await Gal.putVideo(finalPath, album: 'Snatch');
        }

        // Cleanup temp file
        if (directory != null) {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      } catch (e) {
        debugPrint("Save error: $e");
        // If public directory fails, it remains in tempPath
      }

      ref.read(downloadProvider.notifier).updateStatus(id, DownloadStatus.completed, savedPath: finalPath);
      Fluttertoast.showToast(msg: "Downloaded: $title");

    } catch (e) {
      _cancelTokens.remove(id);
      ref.read(downloadProvider.notifier).updateStatus(id, DownloadStatus.failed);
      
      if (e is DioException && CancelToken.isCancel(e)) {
        Fluttertoast.showToast(msg: "Download cancelled: $title");
      } else if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        Fluttertoast.showToast(msg: "No internet connection.");
      } else {
        Fluttertoast.showToast(msg: "Failed to download: $title\nError: $e");
      }
    }
  }

  void cancelDownload(String id) {
    if (_cancelTokens.containsKey(id)) {
      _cancelTokens[id]?.cancel("User cancelled");
      _cancelTokens.remove(id);
    }
  }
}

final downloadManagerProvider = Provider((ref) => DownloadManager());

