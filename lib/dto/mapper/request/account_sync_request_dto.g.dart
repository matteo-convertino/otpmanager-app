// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/account_sync_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountSyncRequestDto _$AccountSyncRequestDtoFromJson(
  Map<String, dynamic> json,
) => AccountSyncRequestDto(
  id: (json['id'] as num).toInt(),
  secret: json['secret'] as String,
  name: json['name'] as String,
  issuer: json['issuer'] as String?,
  algorithm: json['algorithm'] as String,
  digits: (json['digits'] as num).toInt(),
  type: json['type'] as String,
  period: (json['period'] as num).toInt(),
  position: (json['position'] as num?)?.toInt(),
  counter: (json['counter'] as num?)?.toInt(),
  icon: json['icon'] as String,
  deleted: json['deleted'] as bool,
  toUpdate: json['toUpdate'] as bool,
  isNew: json['isNew'] as bool,
);

Map<String, dynamic> _$AccountSyncRequestDtoToJson(
  AccountSyncRequestDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'secret': instance.secret,
  'name': instance.name,
  'issuer': instance.issuer,
  'algorithm': instance.algorithm,
  'digits': instance.digits,
  'type': instance.type,
  'period': instance.period,
  'position': instance.position,
  'counter': instance.counter,
  'icon': instance.icon,
  'deleted': instance.deleted,
  'toUpdate': instance.toUpdate,
  'isNew': instance.isNew,
};
