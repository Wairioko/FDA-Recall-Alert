// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'top_headlines_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RecallResponseModel _$ArticleResponseModelFromJson(Map<String, dynamic> json) {
  return _RecallResponseModel.fromJson(json);
}
mixin _$RecallResponseModel {
  @HiveField(0)
  String? get status => throw _privateConstructorUsedError;
  @HiveField(1)
  String? get product_description => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get classification => throw _privateConstructorUsedError;
  @HiveField(3)
  String? get reason_for_recall => throw _privateConstructorUsedError;
  @HiveField(4)
  String? get recalling_firm => throw _privateConstructorUsedError;
  @HiveField(5)
  String? get voluntary_mandated => throw _privateConstructorUsedError;
  @HiveField(6)
  String? get distribution_pattern => throw _privateConstructorUsedError;
  @HiveField(7)
  dynamic? get event_id => throw _privateConstructorUsedError;
}
/// @nodoc
@JsonSerializable(createToJson: false)
@HiveType(
    typeId: HiveTypeIds.recallEventResponseModel,
    adapterName: 'ArticleResponseModelAdapter')
class _$_ArticleResponseModel extends _RecallResponseModel {
  const _$_ArticleResponseModel(
      @HiveField(0)
      this.status,
      @HiveField(1)
      this.product_description,
      @HiveField(2)
      this.classification,
      @HiveField(3)
      this.reason_for_recall,
      @HiveField(4)
      this.recalling_firm,
      @HiveField(5)
      this.voluntary_mandated,
      @HiveField(6)
      this.distribution_pattern,
      @HiveField(7)
      this.event_id)
      : super._();


  factory _$_ArticleResponseModel.fromJson(Map<String, dynamic> json) =>
      _$$_RecallResponseModelFromJson(json);

  @override
  @HiveField(0)
  final String? status;
  @override
  @HiveField(1)
  final String? product_description;
  @override
  @HiveField(2)
  final String? classification;
  @override
  @HiveField(3)
  final String? reason_for_recall;
  @override
  @HiveField(4)
  final String? recalling_firm;
  @override
  @HiveField(5)
  final String? voluntary_mandated;
  @override
  @HiveField(6)
  final String? distribution_pattern;
  @HiveField(7)
  final dynamic event_id;

  @override
  String toString() {
    return '_$_RecallResponseModel(status: $status, product_description: $product_description, '
        'classification: $classification, reason_for_recall: $reason_for_recall, '
        'recalling_firm: $recalling_firm, voluntary_mandated: $voluntary_mandated,'
        ' distribution_pattern: $distribution_pattern),'
        'event_id: $event_id),'
        ;
  }
}

abstract class _RecallResponseModel extends RecallResponseModel {
  const factory _RecallResponseModel(
      @HiveField(0)
      final String? status,
      @HiveField(1)
      final String? product_description,
      @HiveField(2)
      final String? classification,
      @HiveField(3)
      final String? reason_for_recall,
      @HiveField(4)
      final String? recalling_firm,
      @HiveField(5)
      final String? voluntary_mandated,
      @HiveField(6)
      final String? distribution_pattern,
      @HiveField(7)
      final dynamic event_id
      ) = _$_ArticleResponseModel;
  const _RecallResponseModel._() : super._();

  factory _RecallResponseModel.fromJson(Map<String, dynamic> json) =
      _$_ArticleResponseModel.fromJson;

  @override
  @HiveField(0)
  String? get status;
  @override
  @HiveField(1)
  String? get product_description;
  @override
  @HiveField(2)
  String? get classification;
  @override
  @HiveField(3)
  String? get reason_for_recall;
  @override
  @HiveField(4)
  String? get recalling_firm;
  @override
  @HiveField(5)
  String? get voluntary_mandated;
  @override
  @HiveField(6)
  String? get distribution_pattern;
  @HiveField(7)
  dynamic get event_id;

}