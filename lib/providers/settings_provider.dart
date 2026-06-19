import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String defaultQuality;
  final bool isDarkMode;

  SettingsState({
    required this.defaultQuality,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    String? defaultQuality,
    bool? isDarkMode,
  }) {
    return SettingsState(
      defaultQuality: defaultQuality ?? this.defaultQuality,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  SharedPreferences? _prefs;

  @override
  SettingsState build() {
    _initPrefs();
    return SettingsState(
      defaultQuality: 'Ask Every Time',
      isDarkMode: true,
    );
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final quality = _prefs?.getString('defaultQuality') ?? 'Ask Every Time';
    final darkMode = _prefs?.getBool('isDarkMode') ?? true;
    state = SettingsState(defaultQuality: quality, isDarkMode: darkMode);
  }

  void setDefaultQuality(String quality) {
    state = state.copyWith(defaultQuality: quality);
    _prefs?.setString('defaultQuality', quality);
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
    _prefs?.setBool('isDarkMode', isDark);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
