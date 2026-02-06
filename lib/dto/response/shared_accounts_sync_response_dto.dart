import 'package:json_annotation/json_annotation.dart';
import 'package:otp_manager/dto/response/shared_account_response_dto.dart';

part '../mapper/response/shared_accounts_sync_response_dto.g.dart';

@JsonSerializable()
class SharedAccountsSyncResponseDto {
  const SharedAccountsSyncResponseDto({
    required this.toAdd,
    required this.toEdit,
    required this.toDelete,
  });

  factory SharedAccountsSyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SharedAccountsSyncResponseDtoFromJson(json);

  final List<SharedAccountResponseDto> toAdd;
  final List<SharedAccountResponseDto> toEdit;
  final List<int> toDelete;

  Map<String, dynamic> toJson() => _$SharedAccountsSyncResponseDtoToJson(this);
}
