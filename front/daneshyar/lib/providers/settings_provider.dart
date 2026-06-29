import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';

class Settings {
  final bool darkMode;
  final String apiUrl;
  Settings({this.darkMode = false, this.apiUrl = 'http://localhost:8000'});
  Settings copyWith({bool? darkMode, String? apiUrl}) => Settings(darkMode: darkMode ?? this.darkMode, apiUrl: apiUrl ?? this.apiUrl);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(_loadSettings());
  static Settings _loadSettings() {
    final box = Hive.box('settings');
    return Settings(darkMode: box.get('darkMode', defaultValue: false), apiUrl: box.get('apiUrl', defaultValue: 'http://localhost:8000'));
  }

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
    Hive.box('settings').put('darkMode', state.darkMode);
  }

  void setApiUrl(String url) {
    state = state.copyWith(apiUrl: url);
    Hive.box('settings').put('apiUrl', url);
  }
}