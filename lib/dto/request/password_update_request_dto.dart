import 'package:json_annotation/json_annotation.dart';

part '../mapper/request/password_update_request_dto.g.dart';

@JsonSerializable()
class PasswordUpdateRequestDto {
  const PasswordUpdateRequestDto({
    required this.oldPassword,
    required this.newPassword,
  });

  factory PasswordUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordUpdateRequestDtoFromJson(json);

  final String oldPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => _$PasswordUpdateRequestDtoToJson(this);
}
