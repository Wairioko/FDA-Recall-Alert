import 'package:safe_scan/domain/entities/top_headlines.dart';

abstract class RecallsRepository {
  Future<Recalls?> getRecalls(
    String country,
    String category,
    String query,
    String classification,
    String item
  );
}
