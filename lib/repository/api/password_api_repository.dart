import 'package:dio/dio.dart';
import 'package:otp_manager/dto/request/password_check_request_dto.dart';
import 'package:otp_manager/dto/response/password_check_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/password_api_repository.g.dart';

@RestApi()
abstract class PasswordApiRepository {
  factory PasswordApiRepository(Dio dio, {String? baseUrl}) =
      _PasswordApiRepository;

  @POST('/check')
  Future<PasswordCheckResponseDto> check(
    @Body() PasswordCheckRequestDto passwordCheckRequestDto,
  );
}
