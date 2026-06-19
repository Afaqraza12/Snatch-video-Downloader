import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/download_provider.dart';
import '../providers/shared_intent_provider.dart';
import '../screens/media_player_screen.dart';
import '../services/download_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadTile extends ConsumerWidget {
  final DownloadTask task;

  const DownloadTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(downloadProvider.notifier).removeDownload(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download removed')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: task.status == DownloadStatus.completed && task.savedPath.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaPlayerScreen(
                      filePath: task.savedPath,
                      title: task.title,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: task.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: task.thumbnailUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.platform,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (task.status == DownloadStatus.downloading)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(value: task.progress),
                              const SizedBox(height: 4),
                              Text('${(task.progress * 100).toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            ref.read(downloadManagerProvider).cancelDownload(task.id);
                          },
                        ),
                      ],
                    )
                  else if (task.status == DownloadStatus.completed)
                    Row(
                      children: const [
                        Text('Completed', style: TextStyle(color: Colors.green)),
                        SizedBox(width: 8),
                        Icon(Icons.play_circle_fill, color: Colors.green, size: 16),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Failed', style: TextStyle(color: Colors.red)),
                        if (task.originalUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                            onPressed: () {
                              ref.read(downloadProvider.notifier).removeDownload(task.id);
                              ref.read(sharedUrlProvider.notifier).setSharedUrl(task.originalUrl);
                              if (task.platform == 'YouTube') {
                                ref.read(tabIndexProvider.notifier).setIndex(0);
                              } else if (task.platform == 'TikTok') {
                                ref.read(tabIndexProvider.notifier).setIndex(1);
                              } else if (task.platform == 'Instagram') {
                                ref.read(tabIndexProvider.notifier).setIndex(2);
                              }
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[800],
      child: const Icon(Icons.video_file, size: 40),
    );
  }
}
