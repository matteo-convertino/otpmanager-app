import 'package:dio/dio.dart';
import 'package:otp_manager/dto/request/account_update_counter_request_dto.dart';
import 'package:otp_manager/dto/request/shared_account_unlock_request_dto.dart';
import 'package:otp_manager/dto/response/account_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/shared_account_api_repository.g.dart';

@RestApi()
abstract class SharedAccountApiRepository {
  factory SharedAccountApiRepository(Dio dio, {String? baseUrl}) =
      _SharedAccountApiRepository;

  @POST('/unlock')
  Future<void> unlock(
    @Body() SharedAccountUnlockRequestDto sharedAccountUnlockRequestDto,
  );

  @POST('/update-counter')
  Future<AccountResponseDto> updateCounter(
    @Body() AccountUpdateCounterRequestDto accountUpdateCounterRequestDto,
  );
}
