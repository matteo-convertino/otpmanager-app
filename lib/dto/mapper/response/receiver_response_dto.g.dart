// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/receiver_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiverResponseDto _$ReceiverResponseDtoFromJson(Map<String, dynamic> json) =>
    ReceiverResponseDto(
      id: json['id'] as String,
      label: json['label'] as String?,
      value: json['value'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$ReceiverResponseDtoToJson(
  ReceiverResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'value': instance.value,
  'image': instance.image,
};
