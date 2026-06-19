import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedUrlState {
  final String url;
  final String platform;

  SharedUrlState(this.url, this.platform);
}

class SharedUrlNotifier extends Notifier<SharedUrlState?> {
  @override
  SharedUrlState? build() => null;

  void setSharedUrl(String text) {
    // Extract URL from text
    final RegExp urlRegExp = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})',
      caseSensitive: false,
    );
    
    final match = urlRegExp.firstMatch(text);
    if (match != null) {
      final url = match.group(0)!;
      if (url.contains('youtu')) {
        state = SharedUrlState(url, 'YouTube');
      } else if (url.contains('tiktok')) {
        state = SharedUrlState(url, 'TikTok');
      } else if (url.contains('instagram')) {
        state = SharedUrlState(url, 'Instagram');
      } else {
        state = null;
      }
    }
  }

  void clear() {
    state = null;
  }
}

final sharedUrlProvider = NotifierProvider<SharedUrlNotifier, SharedUrlState?>(() => SharedUrlNotifier());

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final tabIndexProvider = NotifierProvider<TabIndexNotifier, int>(() => TabIndexNotifier());
