import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:research_assistant/app/routes.dart';
import 'package:research_assistant/app/theme.dart';
import 'package:research_assistant/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:research_assistant/models/user_review.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserReviewAdapter()); // بعد از build_runner این خط کار می‌کند
  await Hive.openBox('settings');
  await Hive.openBox('saved_articles');
  await Hive.openBox<UserReview>('user_reviews');
  await Hive.openBox('recent_searches');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider).darkMode;
    return MaterialApp.router(
      title: 'دانش‌یار هوشمند',
      theme: isDark ? AppTheme.dark : AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}