import 'package:dio/dio.dart';
import 'package:otp_manager/utils/api/ocs_unwrap_interceptor.dart';

Dio getOtpManagerDio({required String baseUrl, required String token}) {
  Dio dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/ocs/v2.php/apps/otpmanager',
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': Headers.jsonContentType, // required by OCS controller
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(OcsUnwrapInterceptor());

  return dio;
}
