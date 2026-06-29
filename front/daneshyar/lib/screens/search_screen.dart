import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:research_assistant/models/article.dart';
import 'package:research_assistant/services/api_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedField = 'همه';
  RangeValues _yearRange = RangeValues(2000, 2025);
  List<Article> _results = [];
  bool _isLoading = false;
  bool _searched = false;
  late Box _recentSearchesBox;
  List<String> _recentSearches = [];

  final List<String> _fields = [
    'همه',
    'هوش مصنوعی',
    'علوم سایبری',
    'مخابرات',
    'الکترونیک',
    'مکانیک',
    'هوافضا',
    'کنترل',
  ];

  final Map<String, String> _fieldToId = {
    'همه': '',
    'هوش مصنوعی': 'ai',
    'علوم سایبری': 'cyber',
    'مخابرات': 'telecom_sys',
    'الکترونیک': 'electronics',
    'مکانیک': 'mechanics',
    'هوافضا': 'aerospace',
    'کنترل': 'control',
  };

  @override
  void initState() {
    super.initState();
    _recentSearchesBox = Hive.box('recent_searches');
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    final List<dynamic> saved = _recentSearchesBox.get('list', defaultValue: []);
    setState(() {
      _recentSearches = saved.cast<String>().toList();
    });
  }

  void _saveRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    final updated = [query, ..._recentSearches.where((s) => s != query)].take(10).toList();
    _recentSearchesBox.put('list', updated);
    setState(() {
      _recentSearches = updated;
    });
  }

  void _clearRecentSearches() {
    _recentSearchesBox.delete('list');
    setState(() {
      _recentSearches.clear();
    });
  }

  Future<void> _performSearch() async {
    if (_query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _searched = true;
    });
    _saveRecentSearch(_query);

    final api = ref.read(apiServiceProvider);
    final fieldId = _fieldToId[_selectedField] ?? '';
    final yearFrom = _yearRange.start.toInt();
    final yearTo = _yearRange.end.toInt();

    try {
      final results = await api.searchArticles(
        query: _query,
        field: fieldId,
        yearFrom: yearFrom,
        yearTo: yearTo,
      );
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در جستجو: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.home, color: Colors.white70),
            onPressed: () => context.go('/home'),
            tooltip: 'خانه',
          ),
          title: Text(
            'جستجوی پیشرفته',
            style: TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.cyan)]),
          ),
        ),
        body: Stack(
          children: [
            // Galaxy background
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF0A0F2A), Color(0xFF1A1A3A), Color(0xFF2A1A4A)],
                ),
              ),
            ),
            ..._buildStars(),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildFilters(),
                  SizedBox(height: 16),
                  _buildRecentSearches(),
                  if (_searched) ...[
                    SizedBox(height: 16),
                    _buildResults(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    List<Widget> stars = [];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    for (int i = 0; i < 80; i++) {
      stars.add(Positioned(
        top: (i * 73) % height,
        left: (i * 131) % width,
        child: Container(
          width: (i % 3 + 1).toDouble(),
          height: (i % 3 + 1).toDouble(),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 + (i % 5) * 0.1),
            shape: BoxShape.circle,
          ),
        ),
      ));
    }
    return stars;
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'جستجوی مقالات...',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.search, color: Colors.cyanAccent),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        onSubmitted: (_) {
          setState(() => _query = _searchController.text);
          _performSearch();
        },
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1E2A5E).withOpacity(0.6), Color(0xFF2A1A4A).withOpacity(0.5)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('فیلترها', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fields.map((field) {
              return FilterChip(
                label: Text(field),
                selected: _selectedField == field,
                onSelected: (selected) {
                  setState(() => _selectedField = field);
                },
                backgroundColor: Colors.white10,
                selectedColor: Colors.cyanAccent.shade700,
                labelStyle: TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text('بازه سال: ${_yearRange.start.toInt()} - ${_yearRange.end.toInt()}', style: TextStyle(color: Colors.white70)),
          RangeSlider(
            values: _yearRange,
            min: 1990,
            max: 2025,
            divisions: 35,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.white24,
            onChanged: (values) {
              setState(() => _yearRange = values);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1E2A5E).withOpacity(0.6), Color(0xFF2A1A4A).withOpacity(0.5)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('جستجوهای اخیر', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: _clearRecentSearches,
                child: Text('پاک کردن', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return Chip(
                label: Text(term),
                backgroundColor: Colors.white10,
                labelStyle: TextStyle(color: Colors.white70),
                onDeleted: () {
                  final updated = List<String>.from(_recentSearches)..remove(term);
                  _recentSearchesBox.put('list', updated);
                  setState(() => _recentSearches = updated);
                },
                deleteIcon: Icon(Icons.close, size: 16, color: Colors.white54),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Center(child: SpinKitFadingCircle(color: Colors.cyanAccent));
    }
    if (_results.isEmpty && _searched) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.white38),
            SizedBox(height: 12),
            Text('نتیجه‌ای یافت نشد', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('نتایج (${_results.length})', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final article = _results[index];
            return Card(
              color: Colors.white10,
              margin: EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.cyan.withOpacity(0.2),
                  child: Icon(Icons.article, color: Colors.cyanAccent),
                ),
                title: Text(article.title, style: TextStyle(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${article.authors.join(', ')} (${article.year})', style: TextStyle(color: Colors.white60)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent, size: 16),
                onTap: () => context.push('/article/${article.id}'),
              ),
            );
          },
        ),
      ],
    );
  }
}