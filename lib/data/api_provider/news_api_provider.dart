import 'dart:io';
import 'package:dio/dio.dart';
import '../../model/request_query.dart';
import '../../utility/news_texts.dart';
import '../../utility/utility.dart';
import 'base_api_provider.dart';

class NewsApiProvider extends BaseApiProvider {

  NewsApiProvider() {
    BaseOptions options = createBaseOptions();
    dio = Dio(options);

    dio.interceptors.add(logInterceptor);
    dio.interceptors.add(getLoadingInterceptor());
  }

  //#region Interceptors
  Interceptor logInterceptor =
  LogInterceptor(responseBody: true, requestBody: true, requestHeader: true);

  Interceptor getLoadingInterceptor() => InterceptorsWrapper(
    onRequest: (RequestOptions options,
        RequestInterceptorHandler handler) async {
      Utility.startLoadingAnimation();
      handler.next(options);
    },
    onResponse: (Response response, ResponseInterceptorHandler handler) {
      Utility.completeLoadingAnimation();
      handler.next(response); // continue
    },
    onError: (DioError error, ErrorInterceptorHandler handler) async {
      String errorMessage = NewsTexts.get()['Errorrequesting'];
      if (error.response != null && error.response!.data != null) {
        errorMessage = NewsTexts.get()['Errorrequesting'];
      } else if (error.message!.isNotEmpty) {
        errorMessage = await connectionCheck();
      }
      Utility.showLoadingFailedError(errorMessage);
      handler.next(error);
    },
  );

  Future<String> connectionCheck() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return NewsTexts.get()['noOrSlowInternetConnection'];
      }
    } on SocketException catch (_) {
      return NewsTexts.get()['networkConnectivityError'];
    }
    return NewsTexts.get()['anErrorOccurred'];
  }
  BaseOptions createBaseOptions() {
    DateTime now = DateTime.now();
    String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
    toString().padLeft(2, '0')}";
    String baseUrl = 'https://api.fda.gov/food/enforcement.json?search='
        'report_date:[20231201+TO+$formattedNow]&limit=1000';
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
    );
    return options;
  }
  static String get topHeadlines => '';
}


// String constructUrl(RequestQuery? requestQuery) {
//   DateTime now = DateTime.now();
//   String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${
//       now.day.toString().padLeft(2, '0')}";
//   Uri uri = Uri(
//     scheme: 'https',
//     host: 'api.fda.gov',
//     path: '/food/enforcement.json',
//     queryParameters: {
//       'search': 'report_date:[20231201 TO $formattedNow]',
//       if (requestQuery != null && requestQuery.state.isNotEmpty) 'state': requestQuery.state,
//       if (requestQuery != null && requestQuery.category.isNotEmpty) 'category': requestQuery.category,
//       'limit': '1000',
//     },
//   );
//   print("Constructed URL: $uri");
//   return uri.toString();
// }



// BaseOptions createBaseOptions() {
//   TopHeadlinesQueryParams? queryParams;
//   String baseUrl = 'https://api.fda.gov/food/enforcement.json?';
//   DateTime now = DateTime.now();
//   String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
//   toString().padLeft(2, '0')}";
//   String searchParam = "search=report_date:[20231201+TO+$formattedNow]";
//   if (queryParams != null) {
//     if (queryParams.state.isNotEmpty) {
//       searchParam = "state=${queryParams.state}";
//       print("this is a state search $searchParam");
//     } else if (queryParams.category.isNotEmpty) {
//       searchParam = "category=${queryParams.category}";
//       print("this is a category search $searchParam");
//     }
//   }
//
//   baseUrl += searchParam + '&limit=1000';
//
//   BaseOptions options = BaseOptions(
//     baseUrl: baseUrl,
//   );
//   return options;
// }
// BaseOptions createBaseOptions() {
//   String baseUrl = 'https://api.fda.gov/food/enforcement.json?';
//   DateTime now = DateTime.now();
//   String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
//   toString().padLeft(2, '0')}";
//   String searchParam = "search=report_date:[20231201+TO+$formattedNow]";
//
//   baseUrl += searchParam + '&limit=1000';
//
//   BaseOptions options = BaseOptions(
//     baseUrl: baseUrl,
//   );
//   return options;
// }

//
// class NewsApiProvider extends BaseApiProvider {
//
//   NewsApiProvider({TopHeadlinesQueryParams? queryParams}) {
//     BaseOptions options = createBaseOptions(queryParams);
//     dio = Dio(options);
//
//     dio.interceptors.add(logInterceptor);
//     dio.interceptors.add(getLoadingInterceptor());
//   }
//
//   //#region Interceptors
//   Interceptor logInterceptor =
//   LogInterceptor(responseBody: true, requestBody: true, requestHeader: true);
//
//   Interceptor getLoadingInterceptor() => InterceptorsWrapper(
//     onRequest: (RequestOptions options,
//         RequestInterceptorHandler handler) async {
//       Utility.startLoadingAnimation();
//       handler.next(options);
//     },
//     onResponse: (Response response, ResponseInterceptorHandler handler) {
//       Utility.completeLoadingAnimation();
//       handler.next(response); // continue
//     },
//     onError: (DioError error, ErrorInterceptorHandler handler) async {
//       String errorMessage = NewsTexts.get()['Errorrequesting'];
//       if (error.response != null && error.response!.data != null) {
//         errorMessage = NewsTexts.get()['Errorrequesting'];
//       } else if (error.message!.isNotEmpty) {
//         errorMessage = await connectionCheck();
//       }
//
//       Utility.showLoadingFailedError(errorMessage);
//       handler.next(error);
//     },
//   );
//   //#endregion
//
//   Future<String> connectionCheck() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return NewsTexts.get()['noOrSlowInternetConnection'];
//       }
//     } on SocketException catch (_) {
//       return NewsTexts.get()['networkConnectivityError'];
//     }
//     return NewsTexts.get()['anErrorOccurred'];
//   }
//
//   BaseOptions createBaseOptions(TopHeadlinesQueryParams? queryParams) {
//     String baseUrl = 'https://api.fda.gov/food/enforcement.json?';
//     DateTime now = DateTime.now();
//     String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
//     toString().padLeft(2, '0')}";
//     String searchParam = "search=report_date:[20231201+TO+$formattedNow]";
//     if (queryParams != null) {
//       if (queryParams.state.isNotEmpty) {
//         searchParam = "state=${queryParams.state}";
//       } else if (queryParams.category.isNotEmpty) {
//         searchParam = "category=${queryParams.category}";
//       }
//     }
//
//     baseUrl += searchParam + '&limit=1000';
//
//     BaseOptions options = BaseOptions(
//       baseUrl: baseUrl,
//     );
//     return options;
//   }
//
//   static String get topHeadlines => '';
// }


// BaseOptions createBaseOptions(TopHeadlinesQueryParams? queryParams) {
//   DateTime now = DateTime.now();
//   String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
//   toString().padLeft(2, '0')}";
//
//   Map<String, dynamic> queryParameters = {
//     'search': 'report_date=[20231201+TO+$formattedNow]',
//     'limit': 1000,
//   };
//
//   if (queryParams != null) {
//     // Use state as search parameter if not empty
//     if (queryParams.state.isNotEmpty) {
//       queryParameters['state'] = queryParams.state;
//     }
//
//     // Use category as search parameter if not empty
//     if (queryParams.category.isNotEmpty) {
//       queryParameters['category'] = queryParams.category;
//     }
//
//     // Add other parameters or headers as needed
//   }
//


//





// BaseOptions createBaseOptions() {
//   DateTime now = DateTime.now();
//   String formattedNow =
//       "${now.year}${now.month.toString().padLeft(2, '0')}"
//       "${now.day.toString().padLeft(2, '0')}";
//
//   BaseOptions options = BaseOptions(
//     baseUrl:
//     'https://api.fda.gov/food/enforcement.json?search=report_date:[20231201+TO+$formattedNow]&limit=1000',
//
//   );
//   return options;
// }
// Method to update query parameters dynamically
//   void updateQueryParameters(TopHeadlinesQueryParams? queryParams) {
//     BaseOptions options = createBaseOptions(queryParams);
//     dio.options = options;
//   }



//



// import 'dart:io';
//
// import 'package:daily_news/domain/entities/top_headlines.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import '../../utility/news_texts.dart';
// import '../../utility/utility.dart';
// import '../models/error_response.dart';
// import 'base_api_provider.dart';
//
//
// class NewsApiProvider extends BaseApiProvider {
//
//   NewsApiProvider() {
//     BaseOptions options = createBaseOptions();
//     dio = Dio(options);
//
//     dio.interceptors.add(logInterceptor);
//     dio.interceptors.add(getLoadingInterceptor());
//   }
//
//   //#region Interceptors
//   Interceptor logInterceptor =
//   LogInterceptor(responseBody: true, requestBody: true, requestHeader: true);
//
//   Interceptor getLoadingInterceptor() =>
//       InterceptorsWrapper(
//         onRequest: (RequestOptions options,
//             RequestInterceptorHandler handler) async {
//           Utility.startLoadingAnimation();
//           handler.next(options);
//         },
//         onResponse: (Response _response, ResponseInterceptorHandler handler) {
//           Utility.completeLoadingAnimation();
//           handler.next(_response); // continue
//         },
//         onError: (DioError error, ErrorInterceptorHandler handler) async {
//           String errorMessage = NewsTexts.get()['Errorrequesting'];
//           if (error.response != null && error.response!.data != null) {
//             // var errorResponse = ErrorResponse.fromJson(error.response!.data);
//             errorMessage = NewsTexts.get()['Errorrequesting'];
//           } else if(error.message!.isNotEmpty) {
//             errorMessage = await connectionCheck();
//           }
//
//           Utility.showLoadingFailedError(errorMessage);
//           handler.next(error);
//         },
//       );
//
//   //#endregion
//   Future<String> connectionCheck() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return NewsTexts.get()['noOrSlowInternetConnection'];
//       }
//     } on SocketException catch (_) {
//       return NewsTexts.get()['networkConnectivityError'];
//     }
//     return NewsTexts.get()['anErrorOccurred'];
//   }
//   DateTime now = DateTime.now();
//
//   String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}"
//       "${now.day.toString().padLeft(2, '0')}";
//
//   BaseOptions createBaseOptions() {
//     BaseOptions options =
//     BaseOptions(
//
//         baseUrl: 'https://api.fda.gov/food/enforcement.json?search=limit1000'
//         'search=report_date:[20231201+TO+$formattedNow]&limit=100');
//     // BaseOptions foodoptions = BaseOptions(baseUrl: )
//     return options;
//   }
//
//   static String get topHeadlines => '';
//
// }





//
// import 'dart:io';
//
// import 'package:dio/dio.dart';
//
// import '../../utility/news_texts.dart';
// import '../../utility/utility.dart';
// import '../models/error_response.dart';
// import 'base_api_provider.dart';
//
// class NewsApiProvider extends BaseApiProvider{
//
//   NewsApiProvider() {
//     BaseOptions options = createBaseOptions();
//     dio = Dio(options);
//
//     dio.interceptors.add(logInterceptor);
//     dio.interceptors.add(getLoadingInterceptor());
//   }
//
//   //#region Interceptors
//   Interceptor logInterceptor =
//     LogInterceptor(responseBody: true, requestBody: true, requestHeader: true);
//
//   Interceptor getLoadingInterceptor() => InterceptorsWrapper(
//     onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
//       Utility.startLoadingAnimation();
//       handler.next(options);
//     },
//     onResponse: (Response response, ResponseInterceptorHandler handler) {
//       Utility.completeLoadingAnimation();
//       handler.next(response); // continue
//     },
//     onError: (DioError error, ErrorInterceptorHandler handler) async {
//       String errorMessage = NewsTexts.get()['anErrorOccurred'];
//
//       if (error.response != null && error.response!.data != null) {
//         var errorResponse = ErrorResponse.fromJson(error.response!.data);
//         errorMessage = errorResponse.message ?? NewsTexts.get()['anErrorOccurred'];
//       } else if (error.message.isNotEmpty) {
//         errorMessage = await connectionCheck();
//       }
//
//       Utility.showLoadingFailedError(errorMessage);
//       handler.next(error);
//     },
//   );
//   //#endregion
//
//   Future<String> connectionCheck() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return NewsTexts.get()['noOrSlowInternetConnection'];
//       }
//     } on SocketException catch (_) {
//       return NewsTexts.get()['networkConnectivityError'];
//     }
//     return NewsTexts.get()['anErrorOccurred'];
//   }
//
//   BaseOptions createBaseOptions() {
//     final Map<String, String> _baseHeaders = {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       'Authorization': 'f5135eea2f7748d7b144be1c2fad9c78',
//       "Access-Control-Allow-Origin": "*"
//     };
//     BaseOptions options =
//     BaseOptions(baseUrl: 'https://newsapi.org/v2/', headers: _baseHeaders);
//     return options;
//   }
//
//   static String get topHeadlines => 'top-headlines';
//
// }