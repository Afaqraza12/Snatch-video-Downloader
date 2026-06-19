import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'download_manager.dart';

class InstagramService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final DownloadManager _downloadManager;

  InstagramService(this._downloadManager);

  Future<void> downloadInstagram(WidgetRef ref, String url) async {
    try {
      // Primary API
      final apiUrl = 'https://widipe.com/download/ig?url=$url';
      Response response;
      try {
        response = await _dio.get(apiUrl);
      } catch (_) {
        // Fallback API
        response = await _dio.get('https://aemt.me/instagram?url=$url');
      }
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> results = [];
        
        if (data['result'] is List) {
          results = data['result'];
        } else if (data['url'] != null) {
          results = [data['url']];
        }

        if (results.isNotEmpty) {
          final item = results.first;
          final String downloadUrl = item is String ? item : (item['url'] ?? item['video'] ?? '');

          if (downloadUrl.isEmpty) {
            throw Exception('Could not extract video URL from response.');
          }

          await _downloadManager.startDownload(
            ref: ref,
            url: downloadUrl,
            title: 'Instagram_Video_${DateTime.now().millisecondsSinceEpoch}',
            platform: 'Instagram',
            isVideo: true,
            thumbnailUrl: '',
            originalUrl: url,
          );
        } else {
          throw Exception('No video found at this Instagram link.');
        }
      } else {
        throw Exception('Failed to fetch Instagram video info');
      }
    } catch (e) {
      if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        throw Exception('No internet connection.');
      }
      // Throw error to be caught by the UI
      throw Exception('Instagram fetch error: $e');
    }
  }
}

final instagramServiceProvider = Provider((ref) {
  final dm = ref.watch(downloadManagerProvider);
  return InstagramService(dm);
});
