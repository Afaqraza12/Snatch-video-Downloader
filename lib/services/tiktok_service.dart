import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'download_manager.dart';

class TiktokService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final DownloadManager _downloadManager;

  TiktokService(this._downloadManager);

  Future<void> downloadTiktok(WidgetRef ref, String url) async {
    try {
      final response = await _dio.get('https://www.tikwm.com/api/', queryParameters: {'url': url});
      
      if (response.data != null && response.data['code'] == 0) {
        final data = response.data['data'];
        final downloadUrl = data['play']; // no watermark video
        final title = data['title'] ?? 'TikTok_Video';
        final cover = data['cover'] ?? '';
        
        await _downloadManager.startDownload(
          ref: ref,
          url: downloadUrl,
          title: title,
          platform: 'TikTok',
          isVideo: true,
          thumbnailUrl: cover,
          originalUrl: url,
        );
      } else {
        throw Exception(response.data['msg'] ?? 'Failed to parse TikTok video');
      }
    } catch (e) {
      if (e is DioException && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        throw Exception('No internet connection.');
      }
      throw Exception('TikTok fetch error: $e');
    }
  }
}

final tiktokServiceProvider = Provider((ref) {
  final dm = ref.watch(downloadManagerProvider);
  return TiktokService(dm);
});
