// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../error_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDto _$ErrorDtoFromJson(Map<String, dynamic> json) => ErrorDto(
  status: json['status'] as String,
  statuscode: (json['statuscode'] as num).toInt(),
  message: json['message'] as Object,
);

Map<String, dynamic> _$ErrorDtoToJson(ErrorDto instance) => <String, dynamic>{
  'status': instance.status,
  'statuscode': instance.statuscode,
  'message': instance.message,
};
