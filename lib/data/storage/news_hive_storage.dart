import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import '../models/top_headlines_response.dart';
import 'hive_type_ids.dart';

class NewsHiveStorage {
  static final NewsHiveStorage _instance = NewsHiveStorage._();

  factory NewsHiveStorage() {
    return _instance;
  }

  NewsHiveStorage._();

  static Future<void> init() async {
    await _initHiveAdapters();
  }

  static Future<void> _initHiveAdapters() async {

    Directory directory = await getApplicationDocumentsDirectory();
    Hive.init("${directory.path}/news");

    if (!Hive.isAdapterRegistered(HiveTypeIds.recallsResponse)) Hive.registerAdapter(RecallResponseAdapter());
    if (!Hive.isAdapterRegistered(HiveTypeIds.recallEventResponseModel)) Hive.registerAdapter(RecallResponseModelAdapter());
  }

  static void clear() async {
    await Hive.close();
  }
}