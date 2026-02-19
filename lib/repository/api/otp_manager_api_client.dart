import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/repository/api/account_api_repository.dart';
import 'package:otp_manager/repository/api/password_api_repository.dart';
import 'package:otp_manager/repository/api/shared_account_api_repository.dart';

@LazySingleton()
class OtpManagerApiClient {
  late AccountApiRepository account;
  late SharedAccountApiRepository sharedAccount;
  late PasswordApiRepository password;

  set dio(Dio dio) {
    account = AccountApiRepository(
      dio,
      baseUrl: '${dio.options.baseUrl}/accounts',
    );
    sharedAccount = SharedAccountApiRepository(
      dio,
      baseUrl: '${dio.options.baseUrl}/share',
    );
    password = PasswordApiRepository(
      dio,
      baseUrl: '${dio.options.baseUrl}/password',
    );
  }
}
