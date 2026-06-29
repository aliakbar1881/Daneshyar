import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:research_assistant/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات')),
      body: SwitchListTile(
        title: Text('حالت تاریک'),
        value: settings.darkMode,
        onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
      ),
    );
  }
}