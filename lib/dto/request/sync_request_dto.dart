import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/dto/request/account_sync_request_dto.dart';
import 'package:otp_manager/dto/request/shared_account_sync_request_dto.dart';

part '../mapper/request/sync_request_dto.g.dart';

@JsonSerializable()
class SyncRequestDto {
  const SyncRequestDto({
    required this.accounts,
    required this.sharedAccounts,
    required this.appVersion,
  });

  factory SyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestDtoFromJson(json);

  final List<AccountSyncRequestDto> accounts;
  final List<SharedAccountSyncRequestDto> sharedAccounts;
  final String appVersion;

  Map<String, dynamic> toJson() => _$SyncRequestDtoToJson(this);
}
