import 'package:daily_news/model/detail_data_model.dart';
import 'package:daily_news/utility/news_texts.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/top_headlines.dart';
import '../../../../model/new_item_model.dart';
import 'news_item.dart';

class NewsList extends StatelessWidget {
  final List<Recall_Article> articles;

  const NewsList({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    // Sort the articles list by the status field in descending order

    if (articles.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            InformationTexts.get()["emptyQuery"],
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: articles.map((currentRecall_Item) {
            return Recall_Item(
              newsItemModel: Recall_ItemModel(
                product_description: currentRecall_Item.product_description ?? "",
                reason_for_recall: currentRecall_Item.reason_for_recall ?? "",
                status: currentRecall_Item.status ?? "",
                classification: currentRecall_Item.classification ?? "",
                // imageUrl: currentArticle.urlToImage ?? "",
                detailDataModel: DetailDataModel(
                  product_description: currentRecall_Item.product_description ?? "",
                  reason_for_recall: currentRecall_Item.reason_for_recall ?? "",
                  classification: currentRecall_Item.classification ?? "",
                  recalling_firm: currentRecall_Item.recalling_firm ?? "",
                  status: currentRecall_Item.status ?? "",
                  voluntary_mandated: currentRecall_Item.voluntary_mandated ?? "",
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
