// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/password_update_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordUpdateRequestDto _$PasswordUpdateRequestDtoFromJson(
  Map<String, dynamic> json,
) => PasswordUpdateRequestDto(
  oldPassword: json['oldPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordUpdateRequestDtoToJson(
  PasswordUpdateRequestDto instance,
) => <String, dynamic>{
  'oldPassword': instance.oldPassword,
  'newPassword': instance.newPassword,
};
