import 'package:json_annotation/json_annotation.dart';

part '../mapper/request/account_update_counter_request_dto.g.dart';

@JsonSerializable()
class AccountUpdateCounterRequestDto {
  const AccountUpdateCounterRequestDto({required this.id});

  factory AccountUpdateCounterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AccountUpdateCounterRequestDtoFromJson(json);

  final int id;

  Map<String, dynamic> toJson() => _$AccountUpdateCounterRequestDtoToJson(this);
}
