import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:research_assistant/models/article.dart';
import 'package:research_assistant/services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SubfieldSummaryScreen extends ConsumerStatefulWidget {
  final String compositeId; // e.g. "ai_یادگیری ماشین"
  const SubfieldSummaryScreen({Key? key, required this.compositeId})
    : super(key: key);

  @override
  ConsumerState<SubfieldSummaryScreen> createState() =>
      _SubfieldSummaryScreenState();
}

class _SubfieldSummaryScreenState extends ConsumerState<SubfieldSummaryScreen>
    with SingleTickerProviderStateMixin {
  late String fieldId;
  late String subfieldName;
  late Future<Map<String, dynamic>> _summaryFuture;
  late Future<List<Article>> _articlesFuture;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    final parts = widget.compositeId.split('_');
    fieldId = parts.first;
    subfieldName = parts.sublist(1).join('_');

    _summaryFuture = _fetchSummary();
    _articlesFuture = ref
        .read(apiServiceProvider)
        .fetchArticles(widget.compositeId);

    _starController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchSummary() async {
    try {
      return await ref
          .read(apiServiceProvider)
          .fetchSubfieldSummary(widget.compositeId);
    } catch (e) {
      print("خطا در دریافت خلاصه: $e");
      return {
        'totalArticles': 0,
        'newArticles': 0,
        'keyPoints': ['خطا در ارتباط با سرور'],
        'importantArticles': [],
        'newIdeas': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            subfieldName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 8, color: Colors.cyan)],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0E1A), Color(0xFF1A1A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
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
                  colors: [
                    Color(0xFF0A0F2A),
                    Color(0xFF1A1A3A),
                    Color(0xFF2A1A4A),
                  ],
                ),
              ),
            ),
            // Animated stars
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(_starController.value),
                  size: Size.infinite,
                );
              },
            ),
            // Main content
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        text: 'خلاصه و ایده‌ها',
                        icon: Icon(Icons.auto_awesome),
                      ),
                      Tab(text: 'لیست مقالات', icon: Icon(Icons.list)),
                      Tab(text: 'بهترین‌ها', icon: Icon(Icons.star)),
                    ],
                    labelColor: Colors.cyanAccent,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.cyanAccent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontFamily: 'Vazir',
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSummaryAndIdeas(),
                        _buildArticlesList(),
                        _buildBestArticles(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== تب خلاصه و ایده‌ها ==================
  Widget _buildSummaryAndIdeas() {
    return FutureBuilder(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: SpinKitFadingCircle(color: Colors.cyan));
        final data = snapshot.data!;
        
        // تبدیل صریح انواع داده‌ها
        final totalArticles = data['totalArticles'] ?? 0;
        final newArticles = data['newArticles'] ?? 0;
        final keyPoints = List<String>.from(data['keyPoints'] ?? []);
        final importantArticles = List<dynamic>.from(data['importantArticles'] ?? []);
        final newIdeas = List<String>.from(data['newIdeas'] ?? []);
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(totalArticles, newArticles),
              SizedBox(height: 20),
              _buildKeyPointsCard(keyPoints),
              SizedBox(height: 20),
              _buildImportantArticlesCard(importantArticles),
              SizedBox(height: 20),
              _buildNewIdeasCard(newIdeas),
              SizedBox(height: 20),
              _buildTrendingTopicsCard(),
            ],
          ),
        );
      },
    );
  }
  // ویجت استخراج ترند از مقالات همان گرایش
  Widget _buildTrendingTopicsCard() {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }
        // استخراج کلمات کلیدی پرتکرار از عناوین مقالات (ساده برای نمونه)
        final allTitles = snapshot.data!.map((a) => a.title).join(' ');
        final words = allTitles.split(RegExp(r'\s+'));
        final freq = <String, int>{};
        for (var w in words) {
          // حذف کلمات خیلی کوتاه و اعداد
          if (w.length > 3 && !RegExp(r'^[0-9]+$').hasMatch(w)) {
            freq[w] = (freq[w] ?? 0) + 1;
          }
        }
        final topKeywords = freq.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top5 = topKeywords.take(5).map((e) => e.key).toList();

        return Container(
          padding: EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.cyanAccent),
                  SizedBox(width: 8),
                  Text(
                    '📈 روندهای جاری در این حوزه',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white24, height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: top5
                    .map(
                      (keyword) => Chip(
                        label: Text(
                          keyword,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.cyan.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 8),
              Text(
                'بر اساس جدیدترین مقالات این گرایش',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================== ویجت‌های کمکی ==================
  Widget _buildInfoCard(int total, int newArticles) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(Icons.article, total, 'مجموع مقالات'),
          _infoItem(Icons.fiber_new, newArticles, 'جدید از آخرین بازدید'),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, int value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.cyan.shade300, Colors.blue.shade800],
            ),
            boxShadow: [BoxShadow(color: Colors.cyan, blurRadius: 12)],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 6, color: Colors.cyan)],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  Widget _buildKeyPointsCard(List<String> points) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text(
                'نکات کلیدی',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...points.map(
            (p) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⭐️ ', style: TextStyle(color: Colors.amber)),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantArticlesCard(List<dynamic> articles) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'مقالات مهم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...articles.map(
            (a) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.withOpacity(0.2),
                child: Icon(Icons.article, color: Colors.amber),
              ),
              title: Text(
                a['title'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'سال ${a['year']}',
                style: TextStyle(color: Colors.white60),
              ),
              trailing: Icon(
                Icons.arrow_back_ios,
                color: Colors.cyanAccent,
                size: 16,
              ),
              onTap: () => context.push('/article/${a['id']}'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewIdeasCard(List<String> ideas) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                '💡 ایده‌های نو مرتبط با این گرایش',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...ideas.map(
            (idea) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: Colors.cyanAccent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      idea,
                      style: TextStyle(color: Colors.white70, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: SpinKitFadingCircle(color: Colors.cyan));
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (ctx, i) => Card(
            color: Colors.white10,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.cyan.withOpacity(0.2),
                child: Text('${i + 1}', style: TextStyle(color: Colors.cyan)),
              ),
              title: Text(
                snapshot.data![i].title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '${snapshot.data![i].authors.join(', ')}  (${snapshot.data![i].year})',
                style: TextStyle(color: Colors.white60),
              ),
              trailing: Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
              onTap: () => context.push('/article/${snapshot.data![i].id}'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBestArticles() {
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: SpinKitFadingCircle(color: Colors.cyan));
        var best = List<Article>.from(snapshot.data!);
        best.sort((a, b) => b.credibilityScore.compareTo(a.credibilityScore));
        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: best.length,
          itemBuilder: (ctx, i) => Card(
            color: Colors.white10,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.withOpacity(0.3),
                child: Icon(Icons.star, color: Colors.amber),
              ),
              title: Text(
                best[i].title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'امتیاز اعتبار: ${best[i].credibilityScore.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_back_ios, color: Colors.amber),
              onTap: () => context.push('/article/${best[i].id}'),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1E2A5E).withOpacity(0.8),
          Color(0xFF2A1A4A).withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white24, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }
}

// Star painter for animated background
class StarPainter extends CustomPainter {
  final double time;
  StarPainter(this.time);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (int i = 0; i < 100; i++) {
      double x = (i * 131 + time * 10) % size.width;
      double y = (i * 253 + time * 5) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
