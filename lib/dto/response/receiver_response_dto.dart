import 'package:json_annotation/json_annotation.dart';

part '../mapper/response/receiver_response_dto.g.dart';

@JsonSerializable()
class ReceiverResponseDto {
  const ReceiverResponseDto({
    required this.id,
    this.label,
    this.value,
    this.image,
    this.isExternal,
  });

  factory ReceiverResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReceiverResponseDtoFromJson(json);

  final String id;
  final String? label;
  final String? value;
  final String? image;
  final bool? isExternal;

  Map<String, dynamic> toJson() => _$ReceiverResponseDtoToJson(this);
}
