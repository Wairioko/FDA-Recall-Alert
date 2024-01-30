class DetailDataModel {
  final String status;
  final String reason_for_recall;
  final String voluntary_mandated;
  final String classification;
  final String recalling_firm;
  final String product_description;

  DetailDataModel({
    required this.status,
    required this.reason_for_recall,
    required this.voluntary_mandated,
    required this.classification,
    required this.recalling_firm,
    required this.product_description,
  });
}