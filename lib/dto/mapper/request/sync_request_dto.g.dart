// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/sync_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRequestDto _$SyncRequestDtoFromJson(Map<String, dynamic> json) =>
    SyncRequestDto(
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => AccountSyncRequestDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sharedAccounts: (json['sharedAccounts'] as List<dynamic>)
          .map(
            (e) =>
                SharedAccountSyncRequestDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      appVersion: json['appVersion'] as String,
    );

Map<String, dynamic> _$SyncRequestDtoToJson(SyncRequestDto instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'sharedAccounts': instance.sharedAccounts,
      'appVersion': instance.appVersion,
    };
