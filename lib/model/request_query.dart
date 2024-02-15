class RequestQuery{
  String state;
  String category;
  String query;
  String classification;
  String item;

  RequestQuery(this.state, this.category, this.query, this.classification, this.item);
  bool get isNotEmpty => query.isNotEmpty || state.isNotEmpty ||
      category.isNotEmpty || classification.isNotEmpty || item.isNotEmpty;

}