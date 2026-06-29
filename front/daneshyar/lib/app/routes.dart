import 'package:go_router/go_router.dart';
import 'package:research_assistant/screens/splash_screen.dart';
import 'package:research_assistant/screens/main_menu_screen.dart';
import 'package:research_assistant/screens/articles_list_screen.dart';
import 'package:research_assistant/screens/article_detail_screen.dart';
import 'package:research_assistant/screens/search_screen.dart';
import 'package:research_assistant/screens/saved_screen.dart';
import 'package:research_assistant/screens/history_screen.dart';
import 'package:research_assistant/screens/settings_screen.dart';
import 'package:research_assistant/screens/about_screen.dart';
import 'package:research_assistant/screens/subfield_summary_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => MainMenuScreen()),
    GoRoute(path: '/articles/:subfieldId', builder: (_, state) => ArticlesListScreen(subfieldId: state.pathParameters['subfieldId']!)),
    GoRoute(path: '/article/:articleId', builder: (_, state) => ArticleDetailScreen(articleId: state.pathParameters['articleId']!)),
    GoRoute(path: '/search', builder: (_, __) => SearchScreen()),
    GoRoute(path: '/saved', builder: (_, __) => SavedScreen()),
    GoRoute(path: '/history', builder: (_, __) => HistoryScreen()),
    GoRoute(path: '/settings', builder: (_, __) => SettingsScreen()),
    GoRoute(path: '/about', builder: (_, __) => AboutScreen()),
    // مسیر جدید با یک پارام
    GoRoute(
      path: '/subfield_summary/:compositeId',
      name: 'subfield_summary',
      builder: (context, state) {
        final compositeId = state.pathParameters['compositeId']!;
        return SubfieldSummaryScreen(compositeId: compositeId);
      },
    ),
  ],
);