import 'package:dartz/dartz.dart';
import '../../../core/service_locator.dart';
import '../../../model/request_query.dart';
import '../../models/error_response.dart';
import '../../models/top_headlines_response.dart';
import '../../network/current_weather_api.dart';


abstract class RecallsRemoteDataSource {
  Future<Either<RecallsResponse, ErrorResponse>> getTopHeadlines(
      String state, String category, String query, String classification, String item);
  // Add state and category parameters
}

class TopHeadlinesRemoteDataSourceImpl implements
    RecallsRemoteDataSource {
  late RecallApi _recallApi;

  TopHeadlinesRemoteDataSourceImpl() {
    _recallApi = sl<RecallApi>();
  }

  @override
  Future<Either<RecallsResponse, ErrorResponse>> getTopHeadlines(
      String state, String category, String query, String classification, String item) async {

    _recallApi.requestQuery = RequestQuery(state, category, query, classification, item);

    Either<RecallsResponse, ErrorResponse> response =
    await _recallApi.get();
    return response;
  }
}
