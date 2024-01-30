import 'package:dartz/dartz.dart';
import '../../../core/service_locator.dart';
import '../../models/error_response.dart';
import '../../models/top_headlines_query_params.dart';
import '../../models/top_headlines_response.dart';
import '../../network/current_weather_api.dart';

// abstract class TopHeadlinesRemoteDataSource {
//   Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(
//       TopHeadlinesQueryParams? queryParams);
// }
//
// class TopHeadlinesRemoteDataSourceImpl implements TopHeadlinesRemoteDataSource {
//   late TopHeadlinesApi _topHeadlinesApi;
//
//   TopHeadlinesRemoteDataSourceImpl() {
//     _topHeadlinesApi = sl<TopHeadlinesApi>();
//   }
//
//   @override
//   Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(
//       TopHeadlinesQueryParams? queryParams) async {
//     Either<TopHeadlinesResponse, ErrorResponse> response;
//
//     if (queryParams != null) {
//       // If queryParams is not null, check if state or category is present
//       if (queryParams.state.isNotEmpty) {
//         // Construct URL with state
//         print("state query paramans remote $queryParams");
//         response = await _topHeadlinesApi.get();
//       } else if (queryParams.category.isNotEmpty) {
//         // Construct URL with category
//         response = await _topHeadlinesApi.get();
//       } else {
//         // If neither state nor category is present, use default URL
//         response = await _topHeadlinesApi.get();
//       }
//     } else {
//       // If queryParams is null, use default URL
//       response = await _topHeadlinesApi.get();
//     }
//
//     return response;
//   }
// }

// abstract class TopHeadlinesRemoteDataSource {
//   Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(
//       TopHeadlinesQueryParams? queryParams);
// }
//
// class TopHeadlinesRemoteDataSourceImpl implements TopHeadlinesRemoteDataSource {
//   late TopHeadlinesApi _topHeadlinesApi;
//
//   TopHeadlinesRemoteDataSourceImpl() {
//     _topHeadlinesApi = sl<TopHeadlinesApi>();
//   }
//   @override
//   Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(
//       TopHeadlinesQueryParams? queryParams) async {
//     Either<TopHeadlinesResponse, ErrorResponse> response;
//
//     if (queryParams != null) {
//       response = await _topHeadlinesApi.get();
//     } else {
//       // print("remote data $queryParams");
//       response = await _topHeadlinesApi.get(queryParams: queryParams);
//       // queryParams: queryParams
//     }
//
//     return response;
//   }

//
  // @override
  // Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(TopHeadlinesQueryParams? queryParams) async {
  //   Either<TopHeadlinesResponse, ErrorResponse> response =
  //   await _topHeadlinesApi.get();
  //
  //   // queryParameters: TopHeadlinesQueryParams(state, category).toJson());
  //   return response;
  // }
// }


abstract class TopHeadlinesRemoteDataSource {
  Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines(
      );
  // String state, String category
}
// String country, String category, String query
class TopHeadlinesRemoteDataSourceImpl implements TopHeadlinesRemoteDataSource {
  late TopHeadlinesApi _topHeadlinesApi;

  TopHeadlinesRemoteDataSourceImpl() {
    _topHeadlinesApi = sl<TopHeadlinesApi>();
  }
  // String country, String category,
  // String query
  @override
  Future<Either<TopHeadlinesResponse, ErrorResponse>> getTopHeadlines() async {
    // String state, String category
    Either<TopHeadlinesResponse, ErrorResponse> response =
    await _topHeadlinesApi.get();

    // queryParameters: TopHeadlinesQueryParams(state, category).toJson());
    return response;
  }

  }


