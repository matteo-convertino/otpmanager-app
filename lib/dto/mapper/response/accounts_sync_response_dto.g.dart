// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/accounts_sync_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountsSyncResponseDto _$AccountsSyncResponseDtoFromJson(
  Map<String, dynamic> json,
) => AccountsSyncResponseDto(
  toAdd: (json['toAdd'] as List<dynamic>)
      .map((e) => AccountResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  toEdit: (json['toEdit'] as List<dynamic>)
      .map((e) => AccountResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  toDelete: (json['toDelete'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$AccountsSyncResponseDtoToJson(
  AccountsSyncResponseDto instance,
) => <String, dynamic>{
  'toAdd': instance.toAdd,
  'toEdit': instance.toEdit,
  'toDelete': instance.toDelete,
};
