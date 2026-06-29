import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:research_assistant/models/scientific_field.dart';
import 'package:research_assistant/services/api_service.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFields = ScientificField.getFields();
    final allowedIds = [
      'ai',
      'cyber',
      'telecom_sys',
      'electronics',
      'mechanics',
      'aerospace',
      'control',
    ];
    final fields = allFields
        .where((field) => allowedIds.contains(field.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'داشبورد پژوهشی',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B0E1A), Color(0xFF1A1A3A)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white70),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      drawer: _buildGalaxyDrawer(context),
      body: Stack(
        children: [
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
          ..._buildStars(context),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حوزه‌های علمی',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 4
                          : 3,
                      childAspectRatio: 1 / 1.15,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: fields.length,
                    itemBuilder: (context, index) =>
                        _buildGalaxyCard(fields[index]),
                  ),
                  SizedBox(height: 40),
                  _buildGalaxyStats(),
                  SizedBox(height: 30),
                  _buildIdeasAndGaps(), // <-- Added after stats
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(BuildContext context) {
    List<Widget> stars = [];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    for (int i = 0; i < 50; i++) {
      stars.add(
        Positioned(
          top: (i * 73) % height,
          left: (i * 131) % width,
          child: Container(
            width: (i % 3 + 1).toDouble(),
            height: (i % 3 + 1).toDouble(),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3 + (i % 5) * 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return stars;
  }

  Widget _buildGalaxyStats() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.7),
            Color(0xFF2A1A4A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.article, '۱۲۴', 'مقالات تحلیل شده', Colors.cyan),
          _statItem(Icons.lightbulb, '۱۸', 'ایده‌های جدید', Colors.amber),
          _statItem(
            Icons.trending_up,
            '۷',
            'شکاف تحقیقاتی',
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildGalaxyCard(ScientificField field) {
    return GestureDetector(
      onTap: () => _showGalaxySubfieldsSheet(field),
      child: Card(
        elevation: 12,
        shadowColor: field.color.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                field.color.withOpacity(0.2),
                Color(0xFF1A1A3A).withOpacity(0.8),
              ],
            ),
            border: Border.all(color: field.color.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(field.icon, size: 52, color: field.color),
              SizedBox(height: 12),
              Text(
                field.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: field.color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${field.subfields.length} گرایش',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGalaxySubfieldsSheet(ScientificField field) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1A2F), Color(0xFF1A1A3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 12),
              decoration: BoxDecoration(
                color: field.color.withOpacity(0.2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Row(
                children: [
                  Icon(field.icon, color: field.color, size: 36),
                  SizedBox(width: 12),
                  Text(
                    field.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: field.subfields.length,
                itemBuilder: (ctx, i) => Card(
                  color: Colors.white10,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: field.color.withOpacity(0.3),
                      child: Icon(Icons.star, color: field.color, size: 18),
                    ),
                    title: Text(
                      field.subfields[i],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white54,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      final compositeId = '${field.id}_${field.subfields[i]}';
                      print('Navigating with compositeId: $compositeId');
                      context.push('/subfield_summary/$compositeId');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalaxyDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F2A), Color(0xFF1A1A4A)],
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.auto_awesome, size: 48, color: Colors.cyanAccent),
                  SizedBox(height: 12),
                  Text(
                    'دانش‌یار هوشمند',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'کهکشان پژوهش‌های بین‌رشته‌ای',
                    style: TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ],
              ),
            ),
            _drawerItem(Icons.home, 'خانه', '/home'),
            _drawerItem(Icons.search, 'جستجو', '/search'),
            _drawerItem(Icons.bookmark, 'ذخیره‌ها', '/saved'),
            _drawerItem(Icons.history, 'تاریخچه', '/history'),
            _drawerItem(Icons.settings, 'تنظیمات', '/settings'),
            _drawerItem(Icons.info, 'درباره', '/about'),
            SizedBox(height: 40),
            Divider(color: Colors.white24),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'نسخه ۱.۰.۰ | Galaxy Theme',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String route) {
    final isSelected = route == '/home';
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.cyanAccent : Colors.white60,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.cyanAccent : Colors.white70,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      selected: isSelected,
      selectedTileColor: Colors.white10,
    );
  }

  // -------------------- New widgets for ideas and gaps --------------------
  Widget _buildIdeasAndGaps() {
    return Column(
      children: [
        FutureBuilder<List<String>>(
          future: ref.read(apiServiceProvider).fetchHotIdeas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            return _buildCardSection(
              '💡 ایده‌های داغ بین‌رشته‌ای',
              snapshot.data!,
              Icons.lightbulb,
              Colors.amber,
            );
          },
        ),
        SizedBox(height: 20),
        FutureBuilder<List<String>>(
          future: ref.read(apiServiceProvider).fetchTrendingGaps(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            return _buildCardSection(
              '🔍 شکاف‌های تحقیقاتی اولویت‌دار',
              snapshot.data!,
              Icons.trending_up,
              Colors.greenAccent,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2A5E).withOpacity(0.7),
            Color(0xFF2A1A4A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
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
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_left, color: color, size: 20),
                  Expanded(
                    child: Text(
                      item,
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
}
