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
  digits: $enumDecodeNullable(_$OtpDigitsEnumMap, json['digits']),
  type: $enumDecodeNullable(_$OtpTypeEnumMap, json['type']),
  period: $enumDecodeNullable(_$OtpPeriodEnumMap, json['period']),
  algorithm: $enumDecodeNullable(_$OtpAlgorithmEnumMap, json['algorithm']),
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
  'digits': _$OtpDigitsEnumMap[instance.digits],
  'type': _$OtpTypeEnumMap[instance.type],
  'period': _$OtpPeriodEnumMap[instance.period],
  'algorithm': _$OtpAlgorithmEnumMap[instance.algorithm],
  'counter': instance.counter,
  'userId': instance.userId,
  'deletedAt': instance.deletedAt,
  'receiver': instance.receiver,
  'expiredAt': instance.expiredAt,
  'password': instance.password,
  'iv': instance.iv,
};

const _$OtpDigitsEnumMap = {OtpDigits.d4: 4, OtpDigits.d6: 6};

const _$OtpTypeEnumMap = {OtpType.totp: 'totp', OtpType.hotp: 'hotp'};

const _$OtpPeriodEnumMap = {
  OtpPeriod.p30: 30,
  OtpPeriod.p45: 45,
  OtpPeriod.p60: 60,
};

const _$OtpAlgorithmEnumMap = {
  OtpAlgorithm.sha1: 'SHA1',
  OtpAlgorithm.sha256: 'SHA256',
  OtpAlgorithm.sha512: 'SHA512',
};
