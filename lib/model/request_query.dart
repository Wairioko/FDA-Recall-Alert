class RequestQuery{
  String state;
  String category;
  String query;
  String classification;

  RequestQuery(this.state, this.category, this.query, this.classification);
  bool get isNotEmpty => query.isNotEmpty || state.isNotEmpty ||
      category.isNotEmpty || classification.isNotEmpty ;

}