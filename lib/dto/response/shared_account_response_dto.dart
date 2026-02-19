import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/dto/response/receiver_response_dto.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/utils/enum/otp_algorithm.dart';
import 'package:otp_manager/utils/enum/otp_digits.dart';
import 'package:otp_manager/utils/enum/otp_period.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';

part '../mapper/response/shared_account_response_dto.g.dart';

@JsonSerializable()
class SharedAccountResponseDto {
  const SharedAccountResponseDto({
    required this.id,
    required this.secret,
    required this.name,
    required this.issuer,
    required this.icon,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.unlocked,
    this.digits,
    this.type,
    this.period,
    this.algorithm,
    this.counter,
    this.userId,
    this.deletedAt,
    this.receiver,
    this.expiredAt,
    this.password,
    this.iv,
  });

  factory SharedAccountResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SharedAccountResponseDtoFromJson(json);

  final int id;
  final String secret;
  final String name;
  final String issuer;
  final String icon;
  final int position;
  final String createdAt;
  final String updatedAt;
  final bool unlocked;
  final OtpDigits? digits;
  final OtpType? type;
  final OtpPeriod? period;
  final OtpAlgorithm? algorithm;
  final int? counter;
  final String? userId;
  final String? deletedAt;
  final ReceiverResponseDto? receiver;
  final String? expiredAt;
  final String? password;
  final String? iv;

  Map<String, dynamic> toJson() => _$SharedAccountResponseDtoToJson(this);

  static SharedAccount toModel(SharedAccountResponseDto dto) => SharedAccount(
    encryptedSecret: dto.secret,
    name: dto.name,
    issuer: dto.issuer,
    position: dto.position,
    period: dto.period!.value,
    digits: dto.digits!.value,
    type: dto.type!.value,
    unlocked: dto.unlocked,
    password: dto.password!,
    iv: dto.iv!,
    nextcloudAccountId: dto.id,
    sharerUserId: dto.userId!,
    expiredAt: dto.expiredAt == null ? null : DateTime.parse(dto.expiredAt!),
    dbAlgorithm: dto.algorithm!.index,
    counter: dto.counter,
    iconKey: dto.icon,
  );
}
