import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/youtube_screen.dart';
import 'screens/tiktok_screen.dart';
import 'screens/instagram_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/browser_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/shared_intent_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: SnatchApp()));
}

class SnatchApp extends ConsumerWidget {
  const SnatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Snatch',
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late StreamSubscription _intentStreamSubscription;

  final List<Widget> _screens = [
    const YoutubeScreen(),
    const TiktokScreen(),
    const InstagramScreen(),
    const BrowserScreen(),
    const DownloadsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _intentStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedText(value.first.path);
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedText(value.first.path);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  void _handleSharedText(String text) {
    ref.read(sharedUrlProvider.notifier).setSharedUrl(text);
    final sharedState = ref.read(sharedUrlProvider);
    if (sharedState != null) {
      if (sharedState.platform == 'YouTube') {
        ref.read(tabIndexProvider.notifier).setIndex(0);
      } else if (sharedState.platform == 'TikTok') {
        ref.read(tabIndexProvider.notifier).setIndex(1);
      } else if (sharedState.platform == 'Instagram') {
        ref.read(tabIndexProvider.notifier).setIndex(2);
      }
    }
  }

  @override
  void dispose() {
    _intentStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(tabIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'YouTube',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: 'TikTok',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Instagram',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Browser',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Downloads',
          ),
        ],
      ),
    );
  }
}
