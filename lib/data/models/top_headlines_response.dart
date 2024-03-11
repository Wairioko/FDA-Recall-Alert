import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:safe_scan/data/storage/hive_type_ids.dart';
import 'package:safe_scan/domain/entities/top_headlines.dart';
import 'base_model/base_model.dart';

part 'top_headlines_response.freezed.dart';
part 'top_headlines_response.g.dart';

@JsonSerializable(createToJson: false)
@HiveType(
    typeId: HiveTypeIds.recallsResponse,
    adapterName: 'TopHeadlinesResponseAdapter')
class RecallsResponse extends BaseModel<RecallsResponse> {
  @HiveField(2)
  final List<RecallResponseModel> recall_events;

  RecallsResponse(
      this.recall_events,
      );

  factory RecallsResponse.fromJson(Map<String, dynamic> json) {
    final metaResults = json['results'];

    if (metaResults is List<dynamic>) {
      return RecallsResponse(
        metaResults
            .map((e) => RecallResponseModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else {
      // Handle the case where 'results' is not a List
      // You might want to provide a default value or throw an exception
      print("THIS IS $metaResults");
      return RecallsResponse([]);
    }
  }

  @override
  Map<String, dynamic> toJson() => {};

  Recalls toEntity() => Recalls(
    articles: recall_events.map((e) => e.toEntity()).toList(),
  );
}


@Freezed(copyWith: false, equal: false, toJson: false)
class RecallResponseModel with _$RecallResponseModel {
  const RecallResponseModel._();

  @HiveType(
      typeId: HiveTypeIds.recallEventResponseModel,
      adapterName: 'ArticleResponseModelAdapter')
  const factory RecallResponseModel(
    @HiveField(0)  String? status,
    @HiveField(1)  String? product_description,
    @HiveField(2)  String? classification,
    @HiveField(3)  String? reason_for_recall,
    @HiveField(4)  String? recalling_firm,
    @HiveField(5)  String? voluntary_mandated,
    @HiveField(6)  String? distribution_pattern,
    @HiveField(7)  dynamic event_id,
  ) = _RecallResponseModel;

  factory RecallResponseModel.fromJson(Map<String, dynamic> json) =>
      _$$_RecallResponseModelFromJson(json);

  Recall_Event toEntity() => Recall_Event(
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

