import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/login/login_bloc.dart';
import 'package:otp_manager/bloc/manual/manual_bloc.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/domain/account_service.dart';
import 'package:otp_manager/domain/nextcloud_service.dart';
import 'package:otp_manager/repository/interface/account_repository.dart';
import 'package:otp_manager/repository/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/interface/user_repository.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/web_viewer/web_viewer_bloc.dart';
import '../screens/account_details.dart';
import '../screens/auth.dart';
import '../screens/home/home.dart';
import '../screens/import.dart';
import '../screens/login.dart';
import '../screens/manual.dart';
import '../screens/qr_code_scanner.dart';
import '../screens/settings.dart';
import '../screens/web_viewer.dart';
import 'constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(
              userRepository: context.read<UserRepository>(),
              accountRepository: context.read<AccountRepository>(),
              accountService: context.read<AccountService>(),
              sharedAccountRepository: context.read<SharedAccountRepository>(),
              nextcloudService: context.read<NextcloudService>(),
            ),
            child: const Home(),
          ),
        );
      case importRoute:
        return CupertinoPageRoute(builder: (_) => const Import());
      case settingsRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              userRepository: context.read<UserRepository>(),
            ),
            child: Settings(),
          ),
        );
      case qrCodeScannerRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<QrCodeScannerBloc>(
            create: (context) => QrCodeScannerBloc(
              accountRepository: context.read<AccountRepository>(),
              accountService: context.read<AccountService>(),
            ),
            child: QrCodeScanner(),
          ),
        );
      case accountDetailsRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<AccountDetailsBloc>(
            create: (context) => AccountDetailsBloc(
              userRepository: context.read<UserRepository>(),
              accountRepository: context.read<AccountRepository>(),
              accountService: context.read<AccountService>(),
              sharedAccountRepository: context.read<SharedAccountRepository>(),
              account: settings.arguments as dynamic,
            ),
            child: const AccountDetails(),
          ),
        );
      case loginRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              userRepository: context.read<UserRepository>(),
            ),
            child: const Login(),
          ),
        );
      case webViewerRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<WebViewerBloc>(
            create: (context) => WebViewerBloc(
              userRepository: context.read<UserRepository>(),
              nextcloudUrl: settings.arguments as String,
            ),
            child: WebViewer(),
          ),
        );
      case manualRoute:
        Map arguments = settings.arguments as Map;
        var account = arguments["account"];

        return CupertinoPageRoute(
          builder: (_) => BlocProvider<ManualBloc>(
            create: (context) => ManualBloc(
              accountRepository: context.read<AccountRepository>(),
              sharedAccountRepository: context.read<SharedAccountRepository>(),
              accountService: context.read<AccountService>(),
              account: account,
            ),
            child: const Manual(),
          ),
        );
      case authRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              userRepository: context.read<UserRepository>(),
              nextcloudService: context.read<NextcloudService>(),
            ),
            child: Auth(),
          ),
        );
      default:
        return CupertinoPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
