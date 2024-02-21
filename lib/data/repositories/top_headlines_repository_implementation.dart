import 'package:dartz/dartz.dart';
import '../../core/service_locator.dart';
import '../../domain/entities/top_headlines.dart';
import '../../domain/repositories/top_headlines_repository.dart';
import '../models/error_response.dart';
import '../models/top_headlines_query_params.dart';
import '../models/top_headlines_response.dart';
import 'data_sources/top_headlines_local_data_source.dart';
import 'data_sources/top_headlines_remote_data_source.dart';

class RecallsRepositoryImpl implements RecallsRepository {
  late RecallsRemoteDataSource _recallsRemoteDataSource;
  late RecallsLocalDataSource _recallsLocalDataSource;

  RecallsRepositoryImpl() {
    _recallsRemoteDataSource = sl.get<RecallsRemoteDataSource>();
    _recallsLocalDataSource = sl.get<RecallsLocalDataSource>();
  }

  @override
  Future<Recalls?> getRecalls(String state, String category, String query,
      String classification, String item) async {

    Either<RecallsResponse, ErrorResponse> response =
    await _recallsRemoteDataSource.getTopHeadlines(state, category, query, classification, item);
    //
    var result = response.fold(
          (apiResponse) async {
        _recallsLocalDataSource.putTopHeadlinesResponse(apiResponse, state, category);
        return apiResponse.toEntity();
      },
          (error) async {
        var localResponse =
        await _recallsLocalDataSource.getTopHeadlinesResponse(state, category);
        if (localResponse != null) {
          return localResponse.toEntity();
        } else {
          return null;
        }
      },
    );

    return result;
  }
}
