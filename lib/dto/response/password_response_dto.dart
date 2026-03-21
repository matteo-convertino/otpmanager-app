import 'package:json_annotation/json_annotation.dart';

part '../mapper/response/password_response_dto.g.dart';

@JsonSerializable()
class PasswordResponseDto {
  const PasswordResponseDto({required this.iv});

  factory PasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordResponseDtoFromJson(json);

  final String iv;

  Map<String, dynamic> toJson() => _$PasswordResponseDtoToJson(this);
}
