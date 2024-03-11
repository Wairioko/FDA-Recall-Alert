import 'dart:io';
import 'package:dio/dio.dart';
import '../../utility/news_texts.dart';
import '../../utility/utility.dart';
import 'base_api_provider.dart';



DateTime now = DateTime.now();
String formattedNow = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.
toString().padLeft(2, '0')}";


class RecallDataApiProvider extends BaseApiProvider {

  RecallDataApiProvider() {
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
    onError: (DioException error, ErrorInterceptorHandler handler) async {
      String errorMessage = InformationTexts.get()['Errorrequesting'];
      if (error.response != null && error.response!.data != null) {
        errorMessage = InformationTexts.get()['Errorrequesting'];
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
        return InformationTexts.get()['noOrSlowInternetConnection'];
      }
    } on SocketException catch (_) {
      return InformationTexts.get()['networkConnectivityError'];
    }
    return InformationTexts.get()['anErrorOccurred'];
  }




  BaseOptions createBaseOptions() {
    // Call getCategory() method to retrieve category
    String baseUrl = 'https://api.fda.gov/food/enforcement.json?search='
        'report_date:[20230101+TO+$formattedNow]&limit=1000';
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
    );
    // Get the category value
    return options;
  }


  static String get topHeadlines => '';
  static String get drugsRecalls =>  'https://api.fda.gov/drug/enforcement.json?search='
      'report_date:[20230101+TO+$formattedNow]&limit=1000';
  static String get deviceRecalls => 'https://api.fda.gov/device/enforcement.json?search='
      'report_date:[20230101+TO+$formattedNow]&limit=1000';
}

