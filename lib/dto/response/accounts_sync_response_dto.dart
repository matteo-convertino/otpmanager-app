import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/dto/response/account_response_dto.dart';

part '../mapper/response/accounts_sync_response_dto.g.dart';

@JsonSerializable()
class AccountsSyncResponseDto {
  const AccountsSyncResponseDto({
    required this.toAdd,
    required this.toEdit,
    required this.toDelete,
  });

  factory AccountsSyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AccountsSyncResponseDtoFromJson(json);

  final List<AccountResponseDto> toAdd;
  final List<AccountResponseDto> toEdit;
  final List<int> toDelete;

  Map<String, dynamic> toJson() => _$AccountsSyncResponseDtoToJson(this);
}
