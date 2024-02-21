import 'package:hive/hive.dart';
import '../../models/top_headlines_response.dart';

abstract class RecallsLocalDataSource {
  Future<RecallsResponse?> getTopHeadlinesResponse(String state, String category);
  Future<void> putTopHeadlinesResponse(RecallsResponse topHeadlinesResponse, String state
      , String category);
}

class TopHeadlinesLocalDataSourceImpl extends RecallsLocalDataSource {
  String _createKey(String state,
      String category) => "$state/$category";

  Future<Box<RecallsResponse>> _getTopHeadlinesResponseBox() async {
    return await Hive.openBox<RecallsResponse>('TopHeadlineResponse');
  }

  @override
  Future<RecallsResponse?> getTopHeadlinesResponse(
      String state,
      String category,
      ) async{
    Box<RecallsResponse> currentNewsBox = await _getTopHeadlinesResponseBox();
    RecallsResponse? topHeadlinesResponse = currentNewsBox.
    get(_createKey(state, category));
    await currentNewsBox.close();
    return topHeadlinesResponse;
  }

  @override
  Future<void> putTopHeadlinesResponse(
      RecallsResponse topHeadlinesResponse,
      String state,
      String category,

      ) async {
    Box<RecallsResponse> currentNewsBox = await _getTopHeadlinesResponseBox();
    String key = _createKey(state, category);
    await currentNewsBox.delete(key);
    await currentNewsBox.put(key, topHeadlinesResponse);
    await currentNewsBox.flush();
    await currentNewsBox.close();
  }
}
