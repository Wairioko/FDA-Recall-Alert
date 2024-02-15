import 'dart:ffi';

class TopHeadlines {
  TopHeadlines({
    // required this.status,
    // required this.totalResults,
    required this.articles,
  });

  // final String status;
  // final int totalResults;
  final List<Article> articles;
}

class Article {
  Article({
    required this.status,
    required this.product_description,
    required this.reason_for_recall,
    required this.classification,
    required this.recalling_firm,
    required this.distribution_pattern,
    required this.voluntary_mandated,
    required this.event_id

  });

  final String? status;
  final String? product_description;
  final String? classification;
  final String? reason_for_recall;
  final String? voluntary_mandated;
  final String? distribution_pattern;
  final String? recalling_firm;
  final dynamic event_id;

}
