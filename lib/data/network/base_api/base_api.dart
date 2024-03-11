import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../api_provider/base_api_provider.dart';
import '../../models/base_model/base_model.dart';


abstract class BaseApi<TQuery extends BaseModel, TRes extends BaseModel, TErr extends BaseModel> {
  String url;
  BaseApiProvider apiProvider;

  BaseApi(this.url, this.apiProvider);

  Future<Response<Map<String, dynamic>>> getRaw({
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    Response<Map<String, dynamic>> response = await apiProvider.dio.get(
      url,
      options: Options(
        headers: headers ?? {'Content-Type': 'application/json'},
      ),
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Either<TRes, TErr>> get({
    Map<String, String>? headers,
    TQuery? queryParams
  }) async {
    try {
      // Construct the query parameters dynamically
      Map<String, dynamic>? queryParameters = queryParams?.toJson();
      Response<Map<String, dynamic>> response = await getRaw(
        headers: headers,
        queryParameters: queryParameters,
      );
      // Assuming that both TRes and TErr extend BaseModel, the following should work
      return Left(mapSuccessResponse(response.data) as TRes);
    } on DioException catch (err) {
      if (err.response != null && err.response!.data != null) {
        return Right(mapErrorResponse(err.response!.data) as TErr);
      }
      return Right(
        mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
      );
    }
  }
  BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
  BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
}


// abstract class BaseApi<TQuery extends BaseModel, TRes extends BaseModel,
// TErr extends BaseModel> {
//   String url;
//   BaseApiProvider apiProvider;
//   BaseApi(this.url, this.apiProvider);
//
//   String constructUrl(RequestQuery? requestQuery) {
//     DateTime now = DateTime.now();
//     String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${
//         now.day.toString().padLeft(2, '0')}";
//     String baseUrl = 'https://api.fda.gov/food/enforcement.json';
//     String searchParam = "?search=report_date:[20231201+TO+$formattedNow]";
//
//     if (requestQuery != null) {
//       if (requestQuery.state.isNotEmpty) {
//         searchParam += "&state=${requestQuery.state}";
//       } else if (requestQuery.category.isNotEmpty) {
//         searchParam += "&category=${requestQuery.category}";
//       }
//     }
//     return baseUrl + searchParam + '&limit=1000';
//   }
//
//
//   Future<Response<Map<String, dynamic>>> getRaw({
//     Map<String, String>? headers,
//     RequestQuery? queryParameters,
//     // Map<String, dynamic>? queryParameters, // Change the type to RequestQuery
//   }) async {
//     String constructedUrl = constructUrl(queryParameters);
//
//     Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//       constructedUrl,
//       options: Options(
//         headers: headers ?? {'Content-Type': 'application/json'},
//     ),
//       // queryParameters: queryParameters
//     );
//     return response;
//   }
//
//   Future<Either<TRes, TErr>> get({
//     Map<String, String>? headers,
//     TQuery? queryParams,
//   }) async {
//     try {
//       // Construct the query parameters dynamically
//       // Map<String, dynamic>? queryParameters = queryParams?.toJson();
//
//       Response<Map<String, dynamic>> response = await getRaw(
//         headers: headers,
//         // queryParameters: queryParameters,
//       );
//
//       // Assuming that both TRes and TErr extend BaseModel, the following should work
//       return Left(mapSuccessResponse(response.data) as TRes);
//     } on DioError catch (err) {
//       if (err.response != null && err.response!.data != null) {
//         return Right(mapErrorResponse(err.response!.data) as TErr);
//       }
//
//       return Right(
//         mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//       );
//     }
//   }
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
// }



// Future<Either<TRes, TErr>> get({
//   Map<String, String>? headers,
//   TQuery? queryParams, // Change the type to TQuery
// }) async {
//   try {
//     // Construct the query parameters dynamically
//     RequestQuery? queryParameters = queryParams?.toJson(); // Assuming toJson() returns RequestQuery
//
//     Response<Map<String, dynamic>> response = await getRaw(
//       headers: headers,
//       queryParameters: queryParameters,
//     );
//
//     // Assuming that both TRes and TErr extend BaseModel, the following should work
//     return Left(mapSuccessResponse(response.data) as TRes);
//   } on DioError catch (err) {
//     if (err.response != null && err.response!.data != null) {
//       return Right(mapErrorResponse(err.response!.data) as TErr);
//     }
//
//     return Right(
//       mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//     );
//   }
// }



// abstract class BaseApi<TQuery extends BaseModel, TRes extends BaseModel, TErr extends BaseModel> {
//   String url;
//   BaseApiProvider apiProvider;
//
//   BaseApi(this.url, this.apiProvider);
//
//   String constructUrl(RequestQuery? requestQuery) {
//     DateTime now = DateTime.now();
//     String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
//     String baseUrl = 'https://api.fda.gov/food/enforcement.json';
//     String searchParam = "?search=report_date:[20231201+TO+$formattedNow]";
//
//     if (requestQuery != null) {
//       if (requestQuery.state.isNotEmpty) {
//         searchParam += "&state=${requestQuery.state}";
//       } else if (requestQuery.category.isNotEmpty) {
//         searchParam += "&category=${requestQuery.category}";
//       }
//     }
//
//     return baseUrl + searchParam + '&limit=1000';
//   }
//
//   Future<Response<Map<String, dynamic>>> getRaw({
//     Map<String, String>? headers,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     String constructedUrl = constructUrl(queryParameters);
//
//     Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//       constructedUrl,
//       options: Options(
//         headers: headers ?? {'Content-Type': 'application/json'},
//       ),
//     );
//     return response;
//   }
//
//   Future<Either<TRes, TErr>> get({
//     Map<String, String>? headers,
//     TQuery? queryParams,
//   }) async {
//     try {
//       // Construct the query parameters dynamically
//       Map<String, dynamic>? queryParameters = queryParams?.toJson();
//
//       Response<Map<String, dynamic>> response = await getRaw(
//         headers: headers,
//         queryParameters: queryParameters,
//       );
//
//       // Assuming that both TRes and TErr extend BaseModel, the following should work
//       return Left(mapSuccessResponse(response.data) as TRes);
//     } on DioError catch (err) {
//       if (err.response != null && err.response!.data != null) {
//         return Right(mapErrorResponse(err.response!.data) as TErr);
//       }
//
//       return Right(
//         mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//       );
//     }
//   }
//
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
// }



// abstract class BaseApi<TQuery extends BaseModel, TRes extends BaseModel, TErr extends BaseModel> {
//   String url;
//   BaseApiProvider apiProvider;
//
//   BaseApi(this.url, this.apiProvider);
//
//   String constructUrl(RequestQuery? requestQuery) {
//     DateTime now = DateTime.now();
//     String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
//     toString().padLeft(2, '0')}";
//     String baseUrl = 'https://api.fda.gov/food/enforcement.json';
//     String searchParam = "?search=report_date:[20231201+TO+$formattedNow]";
//
//     if (requestQuery != null) {
//       if (requestQuery.state.isNotEmpty) {
//         searchParam += "&state=${requestQuery.state}";
//       } else if (requestQuery.category.isNotEmpty) {
//         searchParam += "&category=${requestQuery.category}";
//       }
//     }
//     return baseUrl + searchParam + '&limit=1000';
//   }
//
//   // Inside the getRaw method:
//   Future<Response<Map<String, dynamic>>> getRaw({
//     Map<String, String>? headers,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     // Convert queryParameters to RequestQuery
//     RequestQuery? requestQuery = queryParameters != null
//         ? RequestQuery(
//         state: queryParameters['state'],
//         category: queryParameters['category'],
//
//     )
//         : null;
//     String constructedUrl = constructUrl(requestQuery);
//     Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//       constructedUrl,
//       options: Options(
//         headers: headers ?? {'Content-Type': 'application/json'},
//       ),
//       queryParameters: queryParameters,
//     );
//     return response;
//   }
//
//   Future<Either<TRes, TErr>> get({
//     Map<String, String>? headers,
//     TQuery? queryParams,
//   }) async {
//     try {
//       // Construct the query parameters dynamically
//       Map<String, dynamic>? queryParameters = queryParams?.toJson();
//
//       Response<Map<String, dynamic>> response = await getRaw(
//         headers: headers,
//         queryParameters: queryParameters,
//       );
//
//       // Assuming that both TRes and TErr extend BaseModel, the following should work
//       return Left(mapSuccessResponse(response.data) as TRes);
//     } on DioError catch (err) {
//       if (err.response != null && err.response!.data != null) {
//         return Right(mapErrorResponse(err.response!.data) as TErr);
//       }
//
//       return Right(
//         mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//       );
//     }
//   }
//
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
// }

// Future<Response<Map<String, dynamic>>> getRaw({
//   Map<String, String>? headers,
//   Map<String, dynamic>? queryParameters,
// }) async {
//   String constructedUrl = constructUrl(queryParameters);
//
//   Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//     constructedUrl,
//     options: Options(
//       headers: headers ?? {'Content-Type': 'application/json'},
//     ),
//     queryParameters: queryParameters,
//   );
//   return response;
// }







// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../api_provider/base_api_provider.dart';
// import '../../models/base_model/base_model.dart';
//
//
// abstract class BaseApi<TQuery extends BaseModel, TRes extends BaseModel, TErr extends BaseModel> {
//   String url;
//   BaseApiProvider apiProvider;
//
//   BaseApi(this.url, this.apiProvider);
//
//   Future<Response<Map<String, dynamic>>> getRaw({
//     Map<String, String>? headers,
//     Map<String, dynamic>? queryParameters,
//   }) async {
//     Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//       url,
//       options: Options(
//         headers: headers ?? {'Content-Type': 'application/json'},
//         // sendTimeout: BaseApiProvider.connectTimeout,
//         // receiveTimeout: BaseApiProvider.receiveTimeout,
//       ),
//       queryParameters: queryParameters,
//     );
//     return response;
//   }
//
//   Future<Either<TRes, TErr>> get({
//     Map<String, String>? headers,
//     String? state,
//     String? category,
//   }) async {
//     try {
//       // Construct the query parameters dynamically
//       Map<String, dynamic> queryParameters = {};
//
//       if (state != null) {
//         queryParameters['state'] = state;
//       }
//
//       if (category != null) {
//         queryParameters['category'] = category;
//       }
//
//       Response<Map<String, dynamic>> response = await getRaw(
//         headers: headers,
//         queryParameters: queryParameters,
//       );
//
//       // Assuming that both TRes and TErr extend BaseModel, the following should work
//       return Left(mapSuccessResponse(response.data) as TRes);
//     } on DioError catch (err) {
//       if (err.response != null && err.response!.data != null) {
//         return Right(mapErrorResponse(err.response!.data) as TErr);
//       }
//
//       return Right(
//         mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//       );
//     }
//   }
//
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
// }
//
// Future<Either<TRes, TErr>> get({
//   Map<String, String>? headers,
//   Map<String, dynamic>? queryParameters,
//   String? state, // Add the state parameter
//   String? category, // Add the category parameter
// }) async {
//   try {
//     // Add the state and category query parameters if provided
//     if (state != null) {
//       queryParameters ??= {};
//       queryParameters['state'] = state;
//     }
//     if (category != null) {
//       queryParameters ??= {};
//       queryParameters['category'] = category;
//     }
//
//     Response<Map<String, dynamic>> response =
//     await getRaw(headers: headers, queryParameters: queryParameters);
//     return Left(mapSuccessResponse(response.data) as TRes);
//   } on DioError catch (err) {
//     if (err.response != null && err.response!.data != null) {
//       return Right(mapErrorResponse(err.response!.data) as TErr);
//     }
//     return Right(
//       mapErrorResponse({"cod": 9999, "message": "Internal network error"}) as TErr,
//     );
//   }
// }


// abstract class BaseApi<TRes extends BaseModel, TErr extends BaseModel> {
//   String url;
//   BaseApiProvider apiProvider;
//
//   BaseApi(this.url, this.apiProvider);
//
//   Future<Response<Map<String, dynamic>>> getRaw(
//       {
//         Map<String, String>? headers,
//         Map<String, dynamic>? queryParameters
//       }) async {
//     Response<Map<String, dynamic>> response = await apiProvider.dio.get(
//         url,
//         options: Options(
//           headers: headers ?? {'Content-Type': 'application/json'},
//           // sendTimeout: BaseApiProvider.connectTimeout,
//           // receiveTimeout: BaseApiProvider.receiveTimeout,
//         ),
//         queryParameters: queryParameters
//     );
//     return response;
//   }
//
//   Future<Either<TRes, TErr>> get({Map<String, String>? headers, Map<String, dynamic>?
//   queryParameters}) async {
//
//     try {
//       Response<Map<String, dynamic>> response = await getRaw(headers: headers,
//           queryParameters: queryParameters);
//       return Left(mapSuccessResponse(response.data) as TRes);
//     } on DioError catch (err) {
//       if (err.response != null && err.response!.data != null) {
//         return Right(mapErrorResponse(err.response!.data) as TErr);
//       }
//       return Right(mapErrorResponse({"cod":9999, "message": "Internal network error"}) as TErr);
//     }
//   }
//
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson);
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson);
// }
