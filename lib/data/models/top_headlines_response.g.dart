// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_headlines_response.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecallResponseAdapter extends TypeAdapter<RecallsResponse> {
  @override
  final int typeId = 0;

  // @override
  // TopHeadlinesResponse read(BinaryReader reader) {
  //   final numOfFields = reader.readByte();
  //   final fields = <int, dynamic>{
  //     for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
  //   };
  //
  //   // Assuming "results" is the key you want to extract from the JSON data
  //   final resultsList = (fields[0] as Map<String, dynamic>)['results'] as List;
  //
  //   return TopHeadlinesResponse(
  //     resultsList.cast<ArticleResponseModel>(),
  //   );
  // }

  @override
  RecallsResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    List<RecallResponseModel> articles = [];

    // Check if fields[0] is not null and is a List
    if (fields[0] != null && fields[0] is List) {
      articles = (fields[0] as List).cast<RecallResponseModel>();
    }

    return RecallsResponse(articles);
  }
  // TopHeadlinesResponse read(BinaryReader reader) {
  //   final numOfFields = reader.readByte();
  //   final fields = <int, dynamic>{
  //     for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
  //   };
  //   return TopHeadlinesResponse(
  //     // fields[0] as String,
  //     // fields[1] as int,
  //     (fields[0] as List).cast<ArticleResponseModel>(),
  //   );
  // }

  @override
  void write(BinaryWriter writer, RecallsResponse obj) {
    writer
      ..writeByte(1)
      // ..writeByte(0)
      // ..write(obj.status)
      // ..writeByte(1)
      // ..write(obj.totalResults)
      ..writeByte(2)
      ..write(obj.recall_events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecallResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecallResponseModelAdapter extends TypeAdapter<_$_ArticleResponseModel> {
  @override
  final int typeId = 1;

  @override
  _$_ArticleResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_ArticleResponseModel(
      fields[0] as String?,
      fields[1] as String?,
      fields[2] as String?,
      fields[3] as String?,
      fields[4] as String?,
      fields[5] as String?,
      fields[6] as String?,
      fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$_ArticleResponseModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.product_description)
      ..writeByte(2)
      ..write(obj.classification)
      ..writeByte(3)
      ..write(obj.reason_for_recall)
      ..writeByte(4)
      ..write(obj.recalling_firm)
      ..writeByte(5)
      ..write(obj.voluntary_mandated)
      ..writeByte(6)
      ..write(obj.distribution_pattern)
      ..writeByte(7)
      ..write(obj.event_id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecallResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

// TopHeadlinesResponse _$TopHeadlinesResponseFromJson(Map<String, dynamic> json) {
//   return TopHeadlinesResponse(
//     (json['meta']['results'] as List<dynamic>)
//         .map((e) => ArticleResponseModel.fromJson(e as Map<String, dynamic>))
//         .toList(),
//   );
// }
RecallsResponse _$TopHeadlinesResponseFromJson(Map<String, dynamic> json) {
  final metaResults = json['results'];

  if (metaResults is List<dynamic>) {
    return RecallsResponse(
      metaResults
          .map((e) => RecallResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  } else {
    // Handle the case where 'meta.results' is not a List
    // You might want to provide a default value or throw an exception
    print("THIS IS $metaResults");
    return RecallsResponse([]);
  }
}

_$_ArticleResponseModel _$$_RecallResponseModelFromJson(
        Map<String, dynamic> json) =>
    _$_ArticleResponseModel(
      json['status'] as String?,
      json['product_description'] as String?,
      json['classification'] as String?,
      json['reason_for_recall'] as String?,
      json['recalling_firm'] as String?,
      json['voluntary_mandated'] as String?,
      json['distribution_pattern'] as String?,
      json['event_id'] as dynamic,
    );


