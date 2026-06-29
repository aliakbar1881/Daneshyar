import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:research_assistant/models/article.dart';
import 'package:research_assistant/services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ArticlesListScreen extends ConsumerStatefulWidget {
  final String subfieldId;
  const ArticlesListScreen({Key? key, required this.subfieldId}) : super(key: key);

  @override
  ConsumerState<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends ConsumerState<ArticlesListScreen> {
  late Future<List<Article>> _futureArticles;
  List<Article> _allArticles = [];
  List<Article> _filteredArticles = [];
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'newest'; // newest, mostIdeas, mostCritic

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    _futureArticles = ref.read(apiServiceProvider).fetchArticles(widget.subfieldId);
    _futureArticles.then((articles) {
      setState(() {
        _allArticles = articles;
        _applyFilter();
      });
    });
  }

  void _applyFilter() {
    List<Article> filtered = List.from(_allArticles);
    // فیلتر جستجو
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((a) => a.title.contains(_searchController.text)).toList();
    }
    // مرتب‌سازی
    switch (_filterType) {
      case 'newest':
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'mostIdeas':
        filtered.sort((a, b) => b.crossIdeas.length.compareTo(a.crossIdeas.length));
        break;
      case 'mostCritic':
        filtered.sort((a, b) => b.weaknesses.length.compareTo(a.weaknesses.length));
        break;
    }
    _filteredArticles = filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مقالات ${widget.subfieldId.split('_').last}'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () => _showSearchDialog()),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'newest', child: Text('جدیدترین')),
              PopupMenuItem(value: 'mostIdeas', child: Text('بیشترین ایده‌ها')),
              PopupMenuItem(value: 'mostCritic', child: Text('بیشترین نقدها')),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: _futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitFadingCircle(color: Colors.blue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در بارگذاری مقالات: ${snapshot.error}'));
          }
          if (_filteredArticles.isEmpty) {
            return Center(child: Text('هیچ مقاله‌ای یافت نشد.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              _loadArticles();
              await _futureArticles;
            },
            child: ListView.builder(
              itemCount: _filteredArticles.length,
              itemBuilder: (context, index) {
                final article = _filteredArticles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(article.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${article.authors.join(', ')} (${article.year}) · اعتبار: ${article.credibilityScore.toStringAsFixed(0)}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/article/${article.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('جستجو در مقالات'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(hintText: 'عنوان مقاله...'),
          onChanged: (_) {
            setState(() {
              _applyFilter();
            });
            Navigator.pop(context);
            _showSearchDialog(); // برای به‌روزرسانی
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('بستن')),
        ],
      ),
    );
  }
}