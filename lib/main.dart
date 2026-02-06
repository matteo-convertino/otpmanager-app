import 'dart:io';

import 'package:flutter/material.dart' hide Router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/repository/api/otp_manager_api_client.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/utils/api/get_otp_manager_dio.dart';
import 'package:otp_manager/utils/api/otp_manager_http_overrides.dart';

import 'otp_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // ignore bad server certificate
  HttpOverrides.global = OtpManagerHttpOverrides();

  final userRepository = getIt<UserRepository>();
  final user = userRepository.get();

  final apiClient = getIt<OtpManagerApiClient>();
  if (user != null) {
    apiClient.dio = getOtpManagerDio(
      baseUrl: user.url,
      token: user.appPassword,
    );
  }

  runApp(
    BlocProvider<OtpManagerBloc>(
      create: (_) => getIt<OtpManagerBloc>(),
      child: const OtpManager(),
    ),
  );
}
