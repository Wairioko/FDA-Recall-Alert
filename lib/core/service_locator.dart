import 'package:safe_scan/model/request_query.dart';
import 'package:get_it/get_it.dart';
import '../data/api_provider/news_api_provider.dart';
import '../data/network/current_weather_api.dart';
import '../data/repositories/data_sources/top_headlines_local_data_source.dart';
import '../data/repositories/data_sources/top_headlines_remote_data_source.dart';
import '../data/repositories/top_headlines_repository_implementation.dart';
import '../domain/repositories/top_headlines_repository.dart';


GetIt sl = GetIt.instance;

Future<void> setUpServiceLocators() async {
  await sl.reset();

  sl.registerSingleton<RecallDataApiProvider>(RecallDataApiProvider());
  RequestQuery requestQuery = RequestQuery('', '', '', "", "");
  sl.registerFactory<RecallApi>(() => RecallApi(requestQuery:requestQuery));
  sl.registerFactory<RecallsRemoteDataSource>(() => TopHeadlinesRemoteDataSourceImpl());
  sl.registerFactory<RecallsRepository>(() => RecallsRepositoryImpl());
  sl.registerFactory<RecallsLocalDataSource>(() => TopHeadlinesLocalDataSourceImpl());

}
