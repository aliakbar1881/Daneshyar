import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:research_assistant/models/article.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Box _savedBox;

  @override
  void initState() {
    super.initState();
    _savedBox = Hive.box('saved_articles');
  }

  void _removeArticle(String articleId) async {
    await _savedBox.delete(articleId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مقاله از ذخیره‌ها حذف شد'), behavior: SnackBarBehavior.floating),
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
            'مقالات ذخیره شده',
            style: TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.cyan)]),
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
        // ... rest of the body unchanged (same as previous code)
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
            ValueListenableBuilder(
              valueListenable: _savedBox.listenable(),
              builder: (context, Box box, _) {
                final keys = box.keys.toList();
                if (keys.isEmpty) return _buildEmptyState();
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final articleId = keys[index] as String;
                    final Map<String, dynamic> articleData = Map<String, dynamic>.from(box.get(articleId) as Map);
                    final article = Article.fromJson(articleData);
                    return _buildArticleCard(article);
                  },
                );
              },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.white38),
          SizedBox(height: 16),
          Text(
            'هیچ مقاله‌ای ذخیره نشده است',
            style: TextStyle(fontSize: 18, color: Colors.white54),
          ),
          SizedBox(height: 8),
          Text(
            'با کلیک روی دکمه ذخیره در صفحه مقاله، آن را به این لیست اضافه کنید',
            style: TextStyle(fontSize: 14, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.home),
            label: Text('بازگشت به صفحه اصلی'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Dismissible(
        key: Key(article.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => _removeArticle(article.id),
        child: ListTile(
          onTap: () => context.push('/article/${article.id}'),
          leading: CircleAvatar(
            backgroundColor: Colors.cyan.withOpacity(0.2),
            child: Icon(Icons.article, color: Colors.cyanAccent),
          ),
          title: Text(
            article.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${article.authors.join(', ')} (${article.year})',
            style: TextStyle(color: Colors.white60),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white54),
            onPressed: () => _removeArticle(article.id),
            tooltip: 'حذف',
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}