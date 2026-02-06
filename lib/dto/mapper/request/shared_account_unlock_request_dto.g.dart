// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/shared_account_unlock_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedAccountUnlockRequestDto _$SharedAccountUnlockRequestDtoFromJson(
  Map<String, dynamic> json,
) => SharedAccountUnlockRequestDto(
  accountId: (json['accountId'] as num).toInt(),
  currentPassword: json['currentPassword'] as String,
  tempPassword: json['tempPassword'] as String,
);

Map<String, dynamic> _$SharedAccountUnlockRequestDtoToJson(
  SharedAccountUnlockRequestDto instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'currentPassword': instance.currentPassword,
  'tempPassword': instance.tempPassword,
};
