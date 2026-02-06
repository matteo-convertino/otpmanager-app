// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/account_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountResponseDto _$AccountResponseDtoFromJson(Map<String, dynamic> json) =>
    AccountResponseDto(
      id: (json['id'] as num).toInt(),
      secret: json['secret'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      digits: (json['digits'] as num).toInt(),
      type: json['type'] as String,
      period: (json['period'] as num).toInt(),
      algorithm: json['algorithm'] as String,
      counter: (json['counter'] as num?)?.toInt(),
      icon: json['icon'] as String,
      position: (json['position'] as num).toInt(),
      userId: json['userId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deletedAt: json['deletedAt'] as String?,
    );

Map<String, dynamic> _$AccountResponseDtoToJson(AccountResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret': instance.secret,
      'name': instance.name,
      'issuer': instance.issuer,
      'digits': instance.digits,
      'type': instance.type,
      'period': instance.period,
      'algorithm': instance.algorithm,
      'counter': instance.counter,
      'icon': instance.icon,
      'position': instance.position,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
    };
