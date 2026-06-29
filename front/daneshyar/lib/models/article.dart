class Article {
  final String id;
  final String title;
  final List<String> authors;
  final int year;
  final String summary;
  final List<String> hiddenAssumptions;
  final List<String> weaknesses;
  final List<String> researchGaps;
  final List<String> crossIdeas;
  final double credibilityScore;
  final String pdfUrl;  // اضافه شده

  Article({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.summary,
    required this.hiddenAssumptions,
    required this.weaknesses,
    required this.researchGaps,
    required this.crossIdeas,
    required this.credibilityScore,
    required this.pdfUrl,   // اضافه شده در سازنده
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      authors: List<String>.from(json['authors']),
      year: json['year'],
      summary: json['summary'],
      hiddenAssumptions: List<String>.from(json['hidden_assumptions']),
      weaknesses: List<String>.from(json['weaknesses']),
      researchGaps: List<String>.from(json['research_gaps']),
      crossIdeas: List<String>.from(json['cross_ideas']),
      credibilityScore: json['credibility_score'].toDouble(),
      pdfUrl: json['pdf_url'] ?? '',  // اضافه شده (با مقدار پیش‌فرض خالی)
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'authors': authors,
    'year': year,
    'summary': summary,
    'hidden_assumptions': hiddenAssumptions,
    'weaknesses': weaknesses,
    'research_gaps': researchGaps,
    'cross_ideas': crossIdeas,
    'credibility_score': credibilityScore,
    'pdf_url': pdfUrl,
  };
}