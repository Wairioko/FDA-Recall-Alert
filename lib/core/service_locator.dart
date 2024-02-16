import 'package:daily_news/model/request_query.dart';
import 'package:get_it/get_it.dart';
import '../data/api_provider/news_api_provider.dart';
import '../data/network/current_weather_api.dart';
import '../data/repositories/data_sources/top_headlines_local_data_source.dart';
import '../data/repositories/data_sources/top_headlines_remote_data_source.dart';
import '../data/repositories/top_headlines_repository_implementation.dart';
import '../domain/repositories/top_headlines_repository.dart';
import 'package:daily_news/data/models/top_headlines_query_params.dart';
import 'package:daily_news/ui/screens/home/widgets/query_widget.dart';

GetIt sl = GetIt.instance;

Future<void> setUpServiceLocators() async {
  await sl.reset();

  sl.registerSingleton<NewsApiProvider>(NewsApiProvider());
  RequestQuery requestQuery = RequestQuery('', '', '', "", "");
  sl.registerFactory<TopHeadlinesApi>(() => TopHeadlinesApi(requestQuery:requestQuery));
  sl.registerFactory<TopHeadlinesRemoteDataSource>(() => TopHeadlinesRemoteDataSourceImpl());
  sl.registerFactory<TopHeadlinesRepository>(() => TopHeadlinesRepositoryImpl());
  sl.registerFactory<TopHeadlinesLocalDataSource>(() => TopHeadlinesLocalDataSourceImpl());

}
