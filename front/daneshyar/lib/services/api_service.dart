import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:research_assistant/models/article.dart';
import 'package:riverpod/riverpod.dart';

final apiServiceProvider = Provider(
  (ref) => ApiService(Dio(BaseOptions(baseUrl: 'http://localhost:8000'))),
);

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  // ---------- Article fetching ----------
  Future<List<Article>> fetchArticles(
    String compositeId, {
    int limit = 20,
  }) async {
    try {
      final query = _mapSubfieldToQuery(compositeId);
      print('🔍 Search query: $query (from $compositeId)');

      final response = await _dio.get(
        '/api/articles',
        queryParameters: {'q': query, 'limit': limit},
      );

      final List<dynamic> raw = response.data;
      return raw
          .map(
            (paper) => Article(
              id: paper['id'],
              title: paper['title'],
              authors: List<String>.from(paper['authors']),
              year: paper['year'],
              summary: paper['abstract'] ?? '',
              hiddenAssumptions: [],
              weaknesses: [],
              researchGaps: [],
              crossIdeas: [],
              credibilityScore: 0.0,
              pdfUrl: paper['pdf_url'] ?? '',
            ),
          )
          .toList();
    } on DioException catch (e) {
      print('❌ Fetch error: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<Article> fetchArticleDetail(String articleId) async {
    final response = await _dio.get('/api/articles/$articleId');
    return Article.fromJson(response.data);
  }

  Future<List<Article>> searchArticles({
    required String query,
    String field = '',
    int? yearFrom,
    int? yearTo,
  }) async {
    final params = <String, dynamic>{'q': query};
    if (field.isNotEmpty) params['field'] = field;
    if (yearFrom != null) params['year_from'] = yearFrom;
    if (yearTo != null) params['year_to'] = yearTo;
    final response = await _dio.get('/api/search', queryParameters: params);
    return (response.data as List)
        .map((json) => Article.fromJson(json))
        .toList();
  }

  // ---------- Insights (hot ideas & trending gaps) ----------
  Future<List<String>> fetchHotIdeas({int limit = 5}) async {
    final response = await _dio.get(
      '/api/insights/hot-ideas',
      queryParameters: {'limit': limit},
    );
    return List<String>.from(response.data);
  }

  Future<List<String>> fetchTrendingGaps({int limit = 5}) async {
    final response = await _dio.get(
      '/api/insights/trending-gaps',
      queryParameters: {'limit': limit},
    );
    return List<String>.from(response.data);
  }

  // ---------- Helper mapping ----------
  String _mapSubfieldToQuery(String compositeId) {
    final parts = compositeId.split('_');
    if (parts.length < 2) return compositeId;
    final persian = parts.sublist(1).join('_');

    final Map<String, String> mapping = {
      // AI
      'یادگیری ماشین': 'cat:cs.LG AND "machine learning"',
      'یادگیری عمیق': 'cat:cs.LG AND "deep learning" -machine',
      'پردازش زبان طبیعی': 'cat:cs.CL AND "natural language processing"',
      'بینایی کامپیوتر': 'cat:cs.CV AND "computer vision"',
      'یادگیری تقویتی': 'cat:cs.LG AND "reinforcement learning" -supervised',
      'سیستم‌های عامل (Agentic)': 'cat:cs.MA AND "multi-agent system"',
      'نظریه بازی‌ها': 'cat:cs.GT AND "game theory"',

      // Cyber
      'امنیت تهاجمی (Offensive)': 'cat:cs.CR AND "offensive security"',
      'امنیت تدافعی (Defensive)': 'cat:cs.CR AND "defensive security"',
      'ادله دیجیتال (Forensic)': 'cat:cs.CR AND "digital forensics"',
      'رمزنگاری': 'cat:cs.CR AND cryptography -bitcoin',
      'امنیت شبکه': 'cat:cs.CR AND "network security"',
      'حملات سایبری و تحلیل بدافزار': 'cat:cs.CR AND "malware analysis"',

      // Telecom
      'مخابرات سیستم': 'cat:eess.SP AND "communication systems"',
      'مخابرات میدان': 'cat:eess.SP AND "field communications"',
      'مخابرات نوری': 'cat:eess.SP AND "optical communications"',
      'شبکه‌های بی‌سیم': 'cat:eess.SP AND "wireless networks"',
      'پردازش سیگنال مخابراتی': 'cat:eess.SP AND "signal processing"',

      // Electronics
      'مدار مجتمع': 'cat:cs.ET AND "integrated circuits"',
      'الکترونیک قدرت': 'cat:cs.ET AND "power electronics"',
      'مدارهای فرکانس بالا': 'cat:cs.ET AND "high frequency circuits"',
      'طراحی PCB': 'cat:cs.ET AND "PCB design"',
      'الکترونیک دیجیتال': 'cat:cs.ET AND "digital electronics"',

      // Mechanics
      'جامدات': 'cat:physics.class-ph AND "solid mechanics"',
      'سیالات': 'cat:physics.flu-dyn AND "fluid mechanics"',
      'دینامیک و ارتعاشات': 'cat:physics.class-ph AND "dynamics vibrations"',
      'طراحی اجزاء': 'cat:cs.RO AND "mechanical design"',
      'ترمودینامیک': 'cat:physics.class-ph AND thermodynamics',

      // Aerospace
      'آیرودینامیک': 'cat:physics.flu-dyn AND aerodynamics',
      'پیشرانه': 'cat:astro-ph.IM AND propulsion',
      'ساختارهای فضایی': 'cat:astro-ph.IM AND "space structures"',
      'ناوبری و کنترل ماهواره': 'cat:cs.SY AND "satellite navigation"',
      'دینامیک پرواز': 'cat:cs.SY AND "flight dynamics"',

      // Control
      'کنترل خطی': 'cat:eess.SY AND "linear control"',
      'کنترل غیرخطی': 'cat:eess.SY AND "nonlinear control"',
      'کنترل مقاوم': 'cat:eess.SY AND "robust control"',
      'کنترل تطبیقی': 'cat:eess.SY AND "adaptive control"',
      'کنترل بهینه': 'cat:eess.SY AND "optimal control"',
      'کنترل هوشمند': 'cat:eess.SY AND "intelligent control"',
    };

    return mapping[persian] ?? persian;
  }

  // داخل کلاس ApiService
  Future<Map<String, dynamic>> fetchSubfieldSummary(String compositeId) async {
    try {
      final response = await _dio.get(
        '/api/subfield-summary',
        queryParameters: {'compositeId': compositeId},
      );
      return response.data;
    } on DioException catch (e) {
      print(
        'Error fetching subfield summary: ${e.response?.statusCode} - ${e.response?.data}',
      );
      // در صورت خطا، دیتای پیش‌فرض برگردان
      return {
        'totalArticles': 0,
        'newArticles': 0,
        'keyPoints': ['خطا در دریافت اطلاعات از سرور'],
        'importantArticles': [],
        'newIdeas': [],
      };
    }
  }
  Future<String> analyzeText(String text) async {
    try {
      final response = await _dio.post('/api/analyze-text', data: {'text': text});
      return response.data['comment'];
    } catch (e) {
      print('Error analyzing text: $e');
      return 'خطا در تحلیل متن. لطفاً بعداً تلاش کنید.';
    }
  }
}
