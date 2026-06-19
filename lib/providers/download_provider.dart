import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DownloadStatus { downloading, completed, failed }

class DownloadTask {
  final String id;
  final String title;
  final String thumbnailUrl;
  final double progress;
  final DownloadStatus status;
  final String platform;
  final String savedPath;
  final String originalUrl;

  DownloadTask({
    required this.id,
    required this.title,
    this.thumbnailUrl = '',
    this.progress = 0.0,
    this.status = DownloadStatus.downloading,
    required this.platform,
    this.savedPath = '',
    this.originalUrl = '',
  });

  DownloadTask copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    double? progress,
    DownloadStatus? status,
    String? platform,
    String? savedPath,
    String? originalUrl,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      platform: platform ?? this.platform,
      savedPath: savedPath ?? this.savedPath,
      originalUrl: originalUrl ?? this.originalUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'progress': progress,
      'status': status.index,
      'platform': platform,
      'savedPath': savedPath,
      'originalUrl': originalUrl,
    };
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    int statusIndex = json['status'] ?? 0;
    DownloadStatus parsedStatus = (statusIndex >= 0 && statusIndex < DownloadStatus.values.length) 
        ? DownloadStatus.values[statusIndex] 
        : DownloadStatus.failed;

    return DownloadTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      status: parsedStatus,
      platform: json['platform'] ?? '',
      savedPath: json['savedPath'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
    );
  }
}

class DownloadNotifier extends Notifier<List<DownloadTask>> {
  @override
  List<DownloadTask> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('downloads_cache');
    if (tasksJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(tasksJson);
        final List<DownloadTask> tasks = decodedList.map((item) => DownloadTask.fromJson(item)).toList();
        state = tasks;
      } catch (e) {
        // Handle malformed json or other errors gracefully
      }
    }
  }

  Future<void> _saveToPrefs(List<DownloadTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('downloads_cache', tasksJson);
  }

  void addDownload(DownloadTask task) {
    state = [task, ...state];
    _saveToPrefs(state);
  }

  void updateProgress(String id, double progress) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(progress: progress) else task
    ];
    // Removed _saveToPrefs(state) here to prevent massive I/O spam
  }

  void updateStatus(String id, DownloadStatus status, {String? savedPath}) {
    state = [
      for (final task in state)
        if (task.id == id) 
          task.copyWith(status: status, savedPath: savedPath ?? task.savedPath) 
        else 
          task
    ];
    _saveToPrefs(state);
  }

  void removeDownload(String id) {
    state = state.where((task) => task.id != id).toList();
    _saveToPrefs(state);
  }

  void clearCompleted() {
    state = state.where((task) => task.status == DownloadStatus.downloading).toList();
    _saveToPrefs(state);
  }
}

final downloadProvider = NotifierProvider<DownloadNotifier, List<DownloadTask>>(() {
  return DownloadNotifier();
});
