import '../../data/models/top_headlines_query_params.dart';
import '../../model/request_query.dart';
import '../entities/top_headlines.dart';
import '../repositories/top_headlines_repository.dart';
import 'base_use_case/base_use_case.dart';

class TopHeadlinesUseCase extends BaseUseCase<TopHeadlines?, RequestQuery> {
  final TopHeadlinesRepository _topHeadlinesRepository;

  const TopHeadlinesUseCase(this._topHeadlinesRepository);

  @override
  Future<TopHeadlines?> call(RequestQuery input) async{
      return await _topHeadlinesRepository.
      getTopHeadlines(input.state, input.category, input.query, input.classification,
        input.item
          );
  }
}

// class TopHeadlinesUseCase {
//   final TopHeadlinesRepository _repository;
//
//   TopHeadlinesUseCase(this._repository);
//
//   Future<TopHeadlines?> call(TopHeadlinesQueryParams queryParams) async {
//     return await _repository.getTopHeadlines(
//       queryParams.state,
//       queryParams.category,
//       queryParams.query
//     );
//   }
// }

