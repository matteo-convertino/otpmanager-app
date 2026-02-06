import 'package:json_annotation/json_annotation.dart';

part '../mapper/request/shared_account_unlock_request_dto.g.dart';

@JsonSerializable()
class SharedAccountUnlockRequestDto {
  const SharedAccountUnlockRequestDto({
    required this.accountId,
    required this.currentPassword,
    required this.tempPassword,
  });

  factory SharedAccountUnlockRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SharedAccountUnlockRequestDtoFromJson(json);

  final int accountId;
  final String currentPassword;
  final String tempPassword;

  Map<String, dynamic> toJson() => _$SharedAccountUnlockRequestDtoToJson(this);
}
