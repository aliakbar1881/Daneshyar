import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:research_assistant/models/article.dart';
import 'package:research_assistant/models/user_review.dart';
import 'package:research_assistant/services/api_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:research_assistant/screens/pdf_viewer_screen.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;
  const ArticleDetailScreen({Key? key, required this.articleId})
    : super(key: key);

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<Article> _futureArticle;
  bool _isSaved = false;
  late AnimationController _fadeController;
  late Box<UserReview> _reviewBox;
  UserReview? _userReview;
  bool _isEditingReview = false;

  // Review form controllers
  int _rating = 3;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prosController = TextEditingController();
  final TextEditingController _consController = TextEditingController();

  // Key for scrolling to review section
  final GlobalKey _reviewSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..forward();
    _loadArticle();
    _checkIfSaved();
    _openReviewBox();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _notesController.dispose();
    _prosController.dispose();
    _consController.dispose();
    super.dispose();
  }

  void _loadArticle() {
    _futureArticle = ref
        .read(apiServiceProvider)
        .fetchArticleDetail(widget.articleId);
  }

  void _checkIfSaved() async {
    final box = Hive.box('saved_articles');
    if (mounted) {
      setState(() {
        _isSaved = box.containsKey(widget.articleId);
      });
    }
  }

  void _openReviewBox() async {
    // Just get the already open box - no openBox call
    _reviewBox = Hive.box<UserReview>('user_reviews');

    // Find existing review
    UserReview? existingReview;
    for (var review in _reviewBox.values) {
      if (review.articleId == widget.articleId) {
        existingReview = review;
        break;
      }
    }

    setState(() {
      _userReview = existingReview;
      if (_userReview != null) {
        _rating = _userReview!.rating;
        _notesController.text = _userReview!.notes;
        _prosController.text = _userReview!.pros.join('\n');
        _consController.text = _userReview!.cons.join('\n');
      }
    });
  }

  void _saveReview() async {
    final review = UserReview(
      articleId: widget.articleId,
      rating: _rating,
      notes: _notesController.text,
      pros: _prosController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      cons: _consController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      createdAt: DateTime.now(),
    );
    await _reviewBox.put(widget.articleId, review);
    setState(() {
      _userReview = review;
      _isEditingReview = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ بررسی ذخیره شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteReview() async {
    await _reviewBox.delete(widget.articleId);
    setState(() {
      _userReview = null;
      _isEditingReview = false;
      _rating = 3;
      _notesController.clear();
      _prosController.clear();
      _consController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑 بررسی حذف شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleSave() async {
    final box = Hive.box('saved_articles');
    if (_isSaved) {
      await box.delete(widget.articleId);
    } else {
      final article = await _futureArticle;
      await box.put(widget.articleId, article.toJson());
    }
    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved ? '📌 مقاله ذخیره شد' : '🗑 از ذخیره‌ها حذف شد',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Scroll to review section
  void _scrollToReview() {
    final context = _reviewSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تحلیل مقاله',
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
          actions: [
            // Review button in AppBar
            IconButton(
              icon: Icon(Icons.rate_review, color: Colors.cyanAccent),
              onPressed: _scrollToReview,
              tooltip: 'بررسی مقاله',
            ),
            IconButton(
              icon: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.cyanAccent,
              ),
              onPressed: _toggleSave,
              tooltip: 'ذخیره',
            ),
            IconButton(
              icon: Icon(Icons.share, color: Colors.white70),
              onPressed: () {},
              tooltip: 'اشتراک',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _scrollToReview,
          icon: Icon(Icons.edit_note),
          label: Text('بررسی مقاله'),
          backgroundColor: Colors.cyanAccent.shade700,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            // Stars
            ..._buildStars(),
            // Content
            FadeTransition(
              opacity: _fadeController,
              child: FutureBuilder<Article>(
                future: _futureArticle,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFadingCircle(color: Colors.cyanAccent),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'خطا: ${snapshot.error}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final article = snapshot.data!;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(article),
                        SizedBox(height: 16),
                        _buildViewPaperButton(article),
                        SizedBox(height: 16),
                        _buildGlassCard(
                          title: '📄 خلاصه مقاله',
                          icon: Icons.summarize,
                          child: Text(
                            article.summary,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (article.hiddenAssumptions.isNotEmpty)
                          _buildListCard(
                            '🔍 فرضیات پنهان',
                            article.hiddenAssumptions,
                            Icons.hide_source,
                            Colors.purpleAccent,
                          ),
                        if (article.weaknesses.isNotEmpty)
                          _buildListCard(
                            '⚠️ نقاط ضعف',
                            article.weaknesses,
                            Icons.warning,
                            Colors.orangeAccent,
                          ),
                        if (article.researchGaps.isNotEmpty)
                          _buildListCard(
                            '⚡ شکاف‌ها',
                            article.researchGaps,
                            Icons.trending_up,
                            Colors.greenAccent,
                          ),
                        if (article.crossIdeas.isNotEmpty)
                          _buildListCard(
                            '💡 ایده‌های بین‌رشته‌ای',
                            article.crossIdeas,
                            Icons.lightbulb,
                            Colors.amber,
                          ),
                        _buildCredibilityCard(article.credibilityScore),
                        SizedBox(height: 16),
                        _buildUserReviewSection(),
                        SizedBox(height: 30),
                      ],
                    ),
                  );
                },
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
      stars.add(
        Positioned(
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
        ),
      );
    }
    return stars;
  }

  Widget _buildHeader(Article article) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.8),
            Color(0xFF2A1A4A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 6, color: Colors.cyan)],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.white60),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  article.authors.join(', '),
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.white60),
              SizedBox(width: 6),
              Text('${article.year}', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewPaperButton(Article article) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              pdfUrl: article.pdfUrl,
              paperTitle: article.title,
              paperAbstract: article.summary,
            ),
          ),
        );
      },
      icon: Icon(Icons.picture_as_pdf),
      label: Text('View PDF'),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.6),
            Color(0xFF2A1A4A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white24, height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildListCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.6),
            Color(0xFF2A1A4A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white24, height: 24),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⭐️ ', style: TextStyle(color: color)),
                  Expanded(
                    child: Text(
                      item,
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

  Widget _buildCredibilityCard(double score) {
    Color color = score >= 80
        ? Colors.greenAccent
        : (score >= 50 ? Colors.orangeAccent : Colors.redAccent);
    String emoji = score >= 80
        ? '🔬 عالی'
        : (score >= 50 ? '⚠️ متوسط' : '❌ ضعیف');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.6),
            Color(0xFF2A1A4A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: color),
              SizedBox(width: 8),
              Text(
                'امتیاز اعتبار روش',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: TextStyle(color: color)),
              Text(
                '${score.toStringAsFixed(0)} از ۱۰۰',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserReviewSection() {
    return Container(
      key: _reviewSectionKey,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.6),
            Color(0xFF2A1A4A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text(
                'بررسی من',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white24, height: 24),
          if (_isEditingReview) ...[
            _buildRatingSelector(),
            SizedBox(height: 12),
            TextField(
              controller: _notesController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'یادداشت شما...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _prosController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'نکات مثبت (هر خط یک نکته)',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _consController,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'نکات منفی (هر خط یک نکته)',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveReview,
                  child: Text('ذخیره'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _isEditingReview = false),
                  child: Text('انصراف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
                if (_userReview != null)
                  OutlinedButton(
                    onPressed: _deleteReview,
                    child: Text('حذف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
              ],
            ),
          ] else if (_userReview != null) ...[
            Row(
              children: [
                Text('امتیاز: ', style: TextStyle(color: Colors.white70)),
                ..._buildStarsDisplay(_userReview!.rating),
              ],
            ),
            SizedBox(height: 8),
            if (_userReview!.notes.isNotEmpty)
              Text(
                'یادداشت: ${_userReview!.notes}',
                style: TextStyle(color: Colors.white70),
              ),
            if (_userReview!.pros.isNotEmpty) ...[
              Text('+ نکات مثبت:', style: TextStyle(color: Colors.greenAccent)),
              ..._userReview!.pros.map(
                (p) => Text('• $p', style: TextStyle(color: Colors.white70)),
              ),
            ],
            if (_userReview!.cons.isNotEmpty) ...[
              Text('- نکات منفی:', style: TextStyle(color: Colors.redAccent)),
              ..._userReview!.cons.map(
                (c) => Text('• $c', style: TextStyle(color: Colors.white70)),
              ),
            ],
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _isEditingReview = true),
              icon: Icon(Icons.edit),
              label: Text('ویرایش بررسی'),
              style: TextButton.styleFrom(foregroundColor: Colors.cyanAccent),
            ),
          ] else ...[
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _isEditingReview = true),
                icon: Icon(Icons.add),
                label: Text('افزودن بررسی شخصی'),
                style: TextButton.styleFrom(foregroundColor: Colors.cyanAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => setState(() => _rating = index + 1),
        );
      }),
    );
  }

  List<Widget> _buildStarsDisplay(int rating) {
    return List.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 18,
      ),
    );
  }
}
