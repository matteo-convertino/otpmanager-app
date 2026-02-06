import 'package:json_annotation/json_annotation.dart';

part '../mapper/response/password_check_response_dto.g.dart';

@JsonSerializable()
class PasswordCheckResponseDto {
  const PasswordCheckResponseDto({required this.iv});

  factory PasswordCheckResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordCheckResponseDtoFromJson(json);

  final String iv;

  Map<String, dynamic> toJson() => _$PasswordCheckResponseDtoToJson(this);
}
