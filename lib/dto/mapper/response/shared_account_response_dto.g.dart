// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/shared_account_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedAccountResponseDto _$SharedAccountResponseDtoFromJson(
  Map<String, dynamic> json,
) => SharedAccountResponseDto(
  id: (json['id'] as num).toInt(),
  secret: json['secret'] as String,
  name: json['name'] as String,
  issuer: json['issuer'] as String,
  icon: json['icon'] as String,
  position: (json['position'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
  unlocked: json['unlocked'] as bool,
  digits: (json['digits'] as num?)?.toInt(),
  type: json['type'] as String?,
  period: (json['period'] as num?)?.toInt(),
  algorithm: json['algorithm'] as String?,
  counter: (json['counter'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  deletedAt: json['deletedAt'] as String?,
  receiver: json['receiver'] == null
      ? null
      : ReceiverResponseDto.fromJson(json['receiver'] as Map<String, dynamic>),
  expiredAt: json['expiredAt'] as String?,
  password: json['password'] as String?,
  iv: json['iv'] as String?,
);

Map<String, dynamic> _$SharedAccountResponseDtoToJson(
  SharedAccountResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'secret': instance.secret,
  'name': instance.name,
  'issuer': instance.issuer,
  'icon': instance.icon,
  'position': instance.position,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'unlocked': instance.unlocked,
  'digits': instance.digits,
  'type': instance.type,
  'period': instance.period,
  'algorithm': instance.algorithm,
  'counter': instance.counter,
  'userId': instance.userId,
  'deletedAt': instance.deletedAt,
  'receiver': instance.receiver,
  'expiredAt': instance.expiredAt,
  'password': instance.password,
  'iv': instance.iv,
};
