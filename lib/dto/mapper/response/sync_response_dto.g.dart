// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/sync_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResponseDto _$SyncResponseDtoFromJson(Map<String, dynamic> json) =>
    SyncResponseDto(
      accounts: AccountsSyncResponseDto.fromJson(
        json['accounts'] as Map<String, dynamic>,
      ),
      sharedAccounts: SharedAccountsSyncResponseDto.fromJson(
        json['sharedAccounts'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SyncResponseDtoToJson(SyncResponseDto instance) =>
    <String, dynamic>{
      'accounts': instance.accounts,
      'sharedAccounts': instance.sharedAccounts,
    };
