// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/shared_account_sync_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedAccountSyncRequestDto _$SharedAccountSyncRequestDtoFromJson(
  Map<String, dynamic> json,
) => SharedAccountSyncRequestDto(
  id: (json['id'] as num).toInt(),
  secret: json['secret'] as String,
  name: json['name'] as String,
  issuer: json['issuer'] as String?,
  position: (json['position'] as num?)?.toInt(),
  icon: json['icon'] as String,
  deleted: json['deleted'] as bool,
  toUpdate: json['toUpdate'] as bool,
  accountId: (json['accountId'] as num).toInt(),
  unlocked: json['unlocked'] as bool,
  expiredAt: json['expiredAt'] as String?,
);

Map<String, dynamic> _$SharedAccountSyncRequestDtoToJson(
  SharedAccountSyncRequestDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'secret': instance.secret,
  'name': instance.name,
  'issuer': instance.issuer,
  'position': instance.position,
  'icon': instance.icon,
  'deleted': instance.deleted,
  'toUpdate': instance.toUpdate,
  'accountId': instance.accountId,
  'unlocked': instance.unlocked,
  'expiredAt': instance.expiredAt,
};
