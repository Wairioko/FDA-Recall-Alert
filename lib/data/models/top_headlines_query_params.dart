import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:daily_news/data/models/base_model/base_model.dart';

part 'top_headlines_query_params.freezed.dart';
part 'top_headlines_query_params.g.dart';

@Freezed(
  copyWith: false,
  equal: false,
)
class TopHeadlinesQueryParams extends BaseModel with _$TopHeadlinesQueryParams {
  const factory TopHeadlinesQueryParams(
      String state,
      String category,
      String query
      ) = _TopHeadlinesQueryParams;
  factory TopHeadlinesQueryParams.fromJson(Map<String, dynamic> json) =>
      _$TopHeadlinesQueryParamsFromJson(json);
}
