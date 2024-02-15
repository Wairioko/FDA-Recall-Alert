import 'dart:ffi';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:daily_news/data/storage/hive_type_ids.dart';
import 'package:daily_news/domain/entities/top_headlines.dart';
import 'base_model/base_model.dart';

part 'top_headlines_response.freezed.dart';
part 'top_headlines_response.g.dart';

@JsonSerializable(createToJson: false)
@HiveType(
    typeId: HiveTypeIds.topHeadlinesResponse,
    adapterName: 'TopHeadlinesResponseAdapter')
class TopHeadlinesResponse extends BaseModel<TopHeadlinesResponse> {
  @HiveField(2)
  final List<ArticleResponseModel> articles;

  TopHeadlinesResponse(
      this.articles,
      );

  factory TopHeadlinesResponse.fromJson(Map<String, dynamic> json) {
    final metaResults = json['results'];

    if (metaResults is List<dynamic>) {
      return TopHeadlinesResponse(
        metaResults
            .map((e) => ArticleResponseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else {
      // Handle the case where 'results' is not a List
      // You might want to provide a default value or throw an exception
      print("THIS IS $metaResults");
      return TopHeadlinesResponse([]);
    }
  }

  @override
  Map<String, dynamic> toJson() => {};

  TopHeadlines toEntity() => TopHeadlines(
    articles: articles.map((e) => e.toEntity()).toList(),
  );
}

// class TopHeadlinesResponse extends BaseModel<TopHeadlinesResponse> {
//   // @HiveField(0)
//   // final String status;
//   // @HiveField(1)
//   // final int totalResults;
//   @HiveField(2)
//   final List<ArticleResponseModel> articles;
//
//   TopHeadlinesResponse(
//     // this.status,
//     // this.totalResults,
//     this.articles,
//
//   );
//
//   factory TopHeadlinesResponse.fromJson(Map<String,
//       dynamic> json) =>
//       _$TopHeadlinesResponseFromJson(json);
//
//   @override
//   Map<String, dynamic> toJson() => {};
//
//   TopHeadlines toEntity() => TopHeadlines(
//         // status: status,
//         // totalResults: totalResults,
//         articles: articles.map((e) => e.toEntity()).toList(),
//       );
// }

@Freezed(copyWith: false, equal: false, toJson: false)
class ArticleResponseModel with _$ArticleResponseModel {
  const ArticleResponseModel._();

  @HiveType(
      typeId: HiveTypeIds.articlesResponseModel,
      adapterName: 'ArticleResponseModelAdapter')
  const factory ArticleResponseModel(
    @HiveField(0)  String? status,
    @HiveField(1)  String? product_description,
    @HiveField(2)  String? classification,
    @HiveField(3)  String? reason_for_recall,
    @HiveField(4)  String? recalling_firm,
    @HiveField(5)  String? voluntary_mandated,
    @HiveField(6)  String? distribution_pattern,
    @HiveField(7)  dynamic event_id,
  ) = _ArticleResponseModel;


  factory ArticleResponseModel.fromJson(Map<String, dynamic> json) =>
      _$$_ArticleResponseModelFromJson(json);

  Article toEntity() => Article(
    status: status,
    product_description: product_description,
    classification: classification,
    reason_for_recall: reason_for_recall,
    recalling_firm: recalling_firm,
    voluntary_mandated: voluntary_mandated,
    distribution_pattern: distribution_pattern,
    event_id: event_id,
  );
}


// const ArticleResponseModel.internalConstructor({
//   required String? status,
//   required String? product_description,
//   required String? classification,
//   required String? reason_for_recall,
//   required String? recalling_firm,
//   required String? voluntary_mandated,
//   required String? distribution_pattern,
// });