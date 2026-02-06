import 'package:json_annotation/json_annotation.dart';

part '../mapper/request/password_check_request_dto.g.dart';

@JsonSerializable()
class PasswordCheckRequestDto {
  const PasswordCheckRequestDto({required this.password});

  factory PasswordCheckRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordCheckRequestDtoFromJson(json);

  final String password;

  Map<String, dynamic> toJson() => _$PasswordCheckRequestDtoToJson(this);
}
