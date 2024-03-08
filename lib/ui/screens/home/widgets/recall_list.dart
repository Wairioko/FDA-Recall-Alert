import 'package:safe_scan/model/detail_data_model.dart';
import 'package:safe_scan/utility/news_texts.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/top_headlines.dart';
import '../../../../model/new_item_model.dart';
import 'recall_item.dart';


class RecallList extends StatelessWidget {
  final List<Recall_Event> articles;

  const RecallList({Key? key, required this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No recall Items available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: articles.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: RecallItem(
              newsItemModel: RecallItemModel(
                product_description: articles[index].product_description ?? "",
                reason_for_recall: articles[index].reason_for_recall ?? "",
                status: articles[index].status ?? "",
                classification: articles[index].classification ?? "",
                detailDataModel: DetailDataModel(
                  product_description: articles[index].product_description ?? "",
                  reason_for_recall: articles[index].reason_for_recall ?? "",
                  classification: articles[index].classification ?? "",
                  recalling_firm: articles[index].recalling_firm ?? "",
                  status: articles[index].status ?? "",
                  voluntary_mandated: articles[index].voluntary_mandated ?? "",
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
