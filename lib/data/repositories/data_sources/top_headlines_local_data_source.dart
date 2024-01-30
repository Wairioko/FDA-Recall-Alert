import 'package:hive/hive.dart';
import '../../models/top_headlines_response.dart';

abstract class TopHeadlinesLocalDataSource {
  Future<TopHeadlinesResponse?> getTopHeadlinesResponse(String state, String category);
  Future<void> putTopHeadlinesResponse(TopHeadlinesResponse topHeadlinesResponse, String state
      , String category);
}

class TopHeadlinesLocalDataSourceImpl extends TopHeadlinesLocalDataSource {
  String _createKey(String state,
      String category) => "$state/$category";

  Future<Box<TopHeadlinesResponse>> _getTopHeadlinesResponseBox() async {
    return await Hive.openBox<TopHeadlinesResponse>('TopHeadlineResponse');
  }

  @override
  Future<TopHeadlinesResponse?> getTopHeadlinesResponse(
      String state,
      String category,
      ) async{
    Box<TopHeadlinesResponse> currentNewsBox = await _getTopHeadlinesResponseBox();
    TopHeadlinesResponse? topHeadlinesResponse = currentNewsBox.
    get(_createKey(state, category));
    await currentNewsBox.close();
    return topHeadlinesResponse;
  }

  @override
  Future<void> putTopHeadlinesResponse(
      TopHeadlinesResponse topHeadlinesResponse,
      String state,
      String category,

      ) async {
    Box<TopHeadlinesResponse> currentNewsBox = await _getTopHeadlinesResponseBox();
    String key = _createKey(state, category);
    await currentNewsBox.delete(key);
    await currentNewsBox.put(key, topHeadlinesResponse);
    await currentNewsBox.flush();
    await currentNewsBox.close();
  }
}
