import '../../model/request_query.dart';
import '../entities/top_headlines.dart';
import '../repositories/top_headlines_repository.dart';
import 'base_use_case/base_use_case.dart';

class RecallUseCase extends BaseUseCase<Recalls?, RequestQuery> {
  final RecallsRepository _topHeadlinesRepository;

  const RecallUseCase(this._topHeadlinesRepository);

  @override
  Future<Recalls?> call(RequestQuery input) async{
      return await _topHeadlinesRepository.
      getRecalls(input.state, input.category, input.query, input.classification,
        input.item
          );
  }
}
