import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'download_manager.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();
  final DownloadManager _downloadManager;

  YoutubeService(this._downloadManager);

  Future<Video> getVideoInfo(String url) async {
    return await _yt.videos.get(url);
  }

  Future<StreamManifest> getManifest(dynamic videoId) async {
    return await _yt.videos.streamsClient.getManifest(videoId);
  }

  Future<void> downloadVideo({
    required WidgetRef ref,
    required String url,
    required Video video,
    required StreamInfo streamInfo,
    required bool isVideo,
  }) async {
    final downloadUrl = streamInfo.url.toString();
    
    await _downloadManager.startDownload(
      ref: ref,
      url: downloadUrl,
      title: video.title,
      platform: 'YouTube',
      isVideo: isVideo,
      thumbnailUrl: video.thumbnails.highResUrl,
    );
  }

  void dispose() {
    _yt.close();
  }
}

final youtubeServiceProvider = Provider((ref) {
  final dm = ref.watch(downloadManagerProvider);
  return YoutubeService(dm);
});
