import 'package:dio/dio.dart';
import 'package:otp_manager/dto/request/account_update_counter_request_dto.dart';
import 'package:otp_manager/dto/request/sync_request_dto.dart';
import 'package:otp_manager/dto/response/account_response_dto.dart';
import 'package:otp_manager/dto/response/sync_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/account_api_repository.g.dart';

@RestApi()
abstract class AccountApiRepository {
  factory AccountApiRepository(Dio dio, {String? baseUrl}) =
      _AccountApiRepository;

  @POST('/sync')
  Future<SyncResponseDto> sync(@Body() SyncRequestDto syncRequestDto);

  @POST('/update-counter')
  Future<AccountResponseDto> updateCounter(
    @Body() AccountUpdateCounterRequestDto accountUpdateCounterRequestDto,
  );
}
