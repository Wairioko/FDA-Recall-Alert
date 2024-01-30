import 'package:dio/dio.dart';

// abstract class BaseApiProvider{
//   late Dio dio;
//
//   static const int connectTimeout = 29000;
//   static const int receiveTimeout = 29000;
// }

abstract class BaseApiProvider {
  late Dio dio;

  static const int connectTimeout = 29000;
  static const int receiveTimeout = 29000;

  // BaseApiProvider() {
  //   dio = Dio()
  //     ..options.connectTimeout = connectTimeout
  //     ..options.receiveTimeout = receiveTimeout;
  // }
}

