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
      digits: $enumDecode(_$OtpDigitsEnumMap, json['digits']),
      type: $enumDecode(_$OtpTypeEnumMap, json['type']),
      period: $enumDecode(_$OtpPeriodEnumMap, json['period']),
      algorithm: $enumDecode(_$OtpAlgorithmEnumMap, json['algorithm']),
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
      'digits': _$OtpDigitsEnumMap[instance.digits]!,
      'type': _$OtpTypeEnumMap[instance.type]!,
      'period': _$OtpPeriodEnumMap[instance.period]!,
      'algorithm': _$OtpAlgorithmEnumMap[instance.algorithm]!,
      'counter': instance.counter,
      'icon': instance.icon,
      'position': instance.position,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
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
