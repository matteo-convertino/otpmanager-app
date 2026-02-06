import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/models/shared_account.dart';

part '../mapper/request/shared_account_sync_request_dto.g.dart';

@JsonSerializable()
class SharedAccountSyncRequestDto {
  const SharedAccountSyncRequestDto({
    required this.id,
    required this.secret,
    required this.name,
    this.issuer,
    this.position,
    required this.icon,
    required this.deleted,
    required this.toUpdate,
    required this.accountId,
    required this.unlocked,
    this.expiredAt,
  });

  factory SharedAccountSyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SharedAccountSyncRequestDtoFromJson(json);

  factory SharedAccountSyncRequestDto.fromModel(SharedAccount sharedAccount) =>
      SharedAccountSyncRequestDto(
        id: sharedAccount.id,
        secret: sharedAccount.encryptedSecret,
        name: sharedAccount.name,
        issuer: sharedAccount.issuer,
        position: sharedAccount.position,
        icon: sharedAccount.iconKey,
        deleted: sharedAccount.deleted,
        toUpdate: sharedAccount.toUpdate,
        accountId: sharedAccount.nextcloudAccountId,
        unlocked: sharedAccount.unlocked,
        expiredAt: sharedAccount.expiredAt.toString(),
      );

  final int id;
  final String secret;
  final String name;
  final String? issuer;
  final int? position;
  final String icon;
  final bool deleted;
  final bool toUpdate;
  final int accountId;
  final bool unlocked;
  final String? expiredAt;

  Map<String, dynamic> toJson() => _$SharedAccountSyncRequestDtoToJson(this);
}
