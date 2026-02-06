import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/dto/response/accounts_sync_response_dto.dart';
import 'package:otp_manager/dto/response/shared_accounts_sync_response_dto.dart';

part '../mapper/response/sync_response_dto.g.dart';

@JsonSerializable()
class SyncResponseDto {
  const SyncResponseDto({required this.accounts, required this.sharedAccounts});

  factory SyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseDtoFromJson(json);

  final AccountsSyncResponseDto accounts;
  final SharedAccountsSyncResponseDto sharedAccounts;

  Map<String, dynamic> toJson() => _$SyncResponseDtoToJson(this);
}
