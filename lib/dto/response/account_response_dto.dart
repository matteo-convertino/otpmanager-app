import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/utils/enum/otp_algorithm.dart';
import 'package:otp_manager/utils/enum/otp_digits.dart';
import 'package:otp_manager/utils/enum/otp_period.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';

part '../mapper/response/account_response_dto.g.dart';

@JsonSerializable()
class AccountResponseDto {
  const AccountResponseDto({
    required this.id,
    required this.secret,
    required this.name,
    required this.issuer,
    required this.digits,
    required this.type,
    required this.period,
    required this.algorithm,
    this.counter,
    required this.icon,
    required this.position,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AccountResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseDtoFromJson(json);

  final int id;
  final String secret;
  final String name;
  final String issuer;
  final OtpDigits digits;
  final OtpType type;
  final OtpPeriod period;
  final OtpAlgorithm algorithm;
  final int? counter;
  final String icon;
  final int position;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Map<String, dynamic> toJson() => _$AccountResponseDtoToJson(this);

  static Account toModel(AccountResponseDto dto) => Account(
    secret: dto.secret,
    name: dto.name,
    issuer: dto.issuer,
    digits: dto.digits.value,
    type: dto.type.value,
    period: dto.period.value,
    position: dto.position,
    counter: dto.counter,
    dbAlgorithm: dto.algorithm.index,
    iconKey: dto.icon,
  );
}
