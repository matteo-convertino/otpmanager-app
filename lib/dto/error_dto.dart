import 'package:json_annotation/json_annotation.dart';

part 'mapper/error_dto.g.dart';

@JsonSerializable()
class ErrorDto {
  const ErrorDto({
    required this.status,
    required this.statuscode,
    required this.message,
  });

  final String status;
  final int statuscode;
  final Object message;

  factory ErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorDtoToJson(this);
}
