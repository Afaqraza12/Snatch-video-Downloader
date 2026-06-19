import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Default YouTube Quality'),
            subtitle: Text(settings.defaultQuality),
            trailing: DropdownButton<String>(
              value: settings.defaultQuality,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'Ask Every Time', child: Text('Ask Every Time')),
                DropdownMenuItem(value: 'Highest Available', child: Text('Highest Available')),
                DropdownMenuItem(value: '1080p', child: Text('1080p')),
                DropdownMenuItem(value: '720p', child: Text('720p')),
                DropdownMenuItem(value: 'Audio Only', child: Text('Audio Only')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(settingsProvider.notifier).setDefaultQuality(val);
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).toggleTheme(val);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
          ),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/snatch_app_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Snatch', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Version 1.5.0', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Created by'),
            subtitle: Text('Afaq Raza'),
          ),
          ListTile(
            leading: const Icon(Icons.brush_outlined),
            title: const Text('Designed by'),
            subtitle: const Text('Mafaz Noor'),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Snatch is completely free and open-source. You are welcome to modify it for your personal needs, provided that proper credit is given to the original creators. This software is strictly for non-commercial use.',
              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('Creation Time'),
            subtitle: Text('June 2026'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Changelog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
            ),
          ),
          const ListTile(
            title: Text('v1.5.0 - Polish & Quality'),
            subtitle: Text('• Download cancellation support\n• URL validation before processing\n• Friendly "No internet" error messages\n• Faster splash screen (1.5s)\n• Connection timeouts to prevent hangs'),
          ),
          const ListTile(
            title: Text('v1.4.0 - UX Improvements'),
            subtitle: Text('• One-tap clipboard paste button\n• Swipe-to-delete download tiles\n• Retry button for failed downloads\n• Batch "Clear All" optimization'),
          ),
          const ListTile(
            title: Text('v1.3.0 - YouTube HD Quality'),
            subtitle: Text('• Added 1080p, 1440p, and 4K video streams\n• Separate Video-Only and Video+Audio sections\n• "Highest Available" now picks true max quality'),
          ),
          const ListTile(
            title: Text('v1.2.0 - Stability & Performance'),
            subtitle: Text('• Fixed media player crash on audio files\n• Fixed crash when downloaded file is deleted\n• Stopped excessive storage writes during downloads\n• Files now saved to /Download/Snatch/ permanently\n• Temp file cleanup after downloads\n• Fixed browser URL encoding'),
          ),
          const ListTile(
            title: Text('v1.1.0 - Major Update'),
            subtitle: Text('• In-App Browser for YouTube/TikTok/Instagram\n• Built-in Video & Audio Player\n• Fixed downloads disappearing on restart'),
          ),
          const ListTile(
            title: Text('v1.0.1 - Bug Fixes'),
            subtitle: Text('• Fixed Instagram Downloader API integration'),
          ),
          const ListTile(
            title: Text('v1.0.0 - Initial Release'),
            subtitle: Text('• Multi-platform Video & Audio Downloads\n• YouTube Quality Selector\n• Share Intent Integration\n• Settings & Preferences'),
          ),
        ],
      ),
    );
  }
}
