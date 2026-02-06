import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/models/account.dart';

part '../mapper/request/account_sync_request_dto.g.dart';

@JsonSerializable()
class AccountSyncRequestDto {
  const AccountSyncRequestDto({
    required this.id,
    required this.secret,
    required this.name,
    this.issuer,
    required this.algorithm,
    required this.digits,
    required this.type,
    required this.period,
    this.position,
    this.counter,
    required this.icon,
    required this.deleted,
    required this.toUpdate,
    required this.isNew,
  });

  factory AccountSyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AccountSyncRequestDtoFromJson(json);

  factory AccountSyncRequestDto.fromModel(Account account) =>
      AccountSyncRequestDto(
        id: account.id,
        secret: account.encryptedSecret!,
        name: account.name,
        issuer: account.issuer,
        algorithm: account.algorithm.name,
        digits: account.digits!,
        type: account.type,
        period: account.period!,
        position: account.position,
        counter: account.counter,
        icon: account.iconKey,
        deleted: account.deleted,
        toUpdate: account.toUpdate,
        isNew: account.isNew,
      );

  final int id;
  final String secret;
  final String name;
  final String? issuer;
  final String algorithm;
  final int digits;
  final String type;
  final int period;
  final int? position;
  final int? counter;
  final String icon;
  final bool deleted;
  final bool toUpdate;
  final bool isNew;

  Map<String, dynamic> toJson() => _$AccountSyncRequestDtoToJson(this);
}
