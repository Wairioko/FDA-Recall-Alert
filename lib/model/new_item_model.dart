import 'detail_data_model.dart';

class RecallItemModel {
  final String product_description;
  final String reason_for_recall;
  final String status;
  final String classification;
  final DetailDataModel detailDataModel;

  RecallItemModel({
    required this.product_description,
    required this.reason_for_recall,
    required this.status,
    required this.classification,
    required this.detailDataModel,
  });
}