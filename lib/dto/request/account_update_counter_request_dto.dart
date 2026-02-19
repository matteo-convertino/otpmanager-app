import 'package:json_annotation/json_annotation.dart';

part '../mapper/request/account_update_counter_request_dto.g.dart';

@JsonSerializable()
class AccountUpdateCounterRequestDto {
  const AccountUpdateCounterRequestDto({required this.secret});

  factory AccountUpdateCounterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AccountUpdateCounterRequestDtoFromJson(json);

  final String secret;

  Map<String, dynamic> toJson() => _$AccountUpdateCounterRequestDtoToJson(this);
}
