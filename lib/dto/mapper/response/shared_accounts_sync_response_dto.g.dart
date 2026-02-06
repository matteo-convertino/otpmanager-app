// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/shared_accounts_sync_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedAccountsSyncResponseDto _$SharedAccountsSyncResponseDtoFromJson(
  Map<String, dynamic> json,
) => SharedAccountsSyncResponseDto(
  toAdd: (json['toAdd'] as List<dynamic>)
      .map((e) => SharedAccountResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  toEdit: (json['toEdit'] as List<dynamic>)
      .map((e) => SharedAccountResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  toDelete: (json['toDelete'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$SharedAccountsSyncResponseDtoToJson(
  SharedAccountsSyncResponseDto instance,
) => <String, dynamic>{
  'toAdd': instance.toAdd,
  'toEdit': instance.toEdit,
  'toDelete': instance.toDelete,
};
