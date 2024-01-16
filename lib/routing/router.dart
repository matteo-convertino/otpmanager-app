import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/login/login_bloc.dart';
import 'package:otp_manager/bloc/manual/manual_bloc.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/domain/nextcloud_service.dart';
import 'package:otp_manager/repository/local_repository.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/web_viewer/web_viewer_bloc.dart';
import '../models/account.dart';
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
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
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
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
            ),
            child: Settings(),
          ),
        );
      case qrCodeScannerRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<QrCodeScannerBloc>(
            create: (context) => QrCodeScannerBloc(
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
            ),
            child: QrCodeScanner(),
          ),
        );
      case accountDetailsRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<AccountDetailsBloc>(
            create: (context) => AccountDetailsBloc(
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
              account: settings.arguments as Account,
            ),
            child: const AccountDetails(),
          ),
        );
      case loginRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
            ),
            child: const Login(),
          ),
        );
      case webViewerRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<WebViewerBloc>(
            create: (context) => WebViewerBloc(
              nextcloudUrl: settings.arguments as String,
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
            ),
            child: const WebViewer(),
          ),
        );
      case manualRoute:
        Map arguments = settings.arguments as Map;
        Account? account = arguments["account"];

        return CupertinoPageRoute(
          builder: (_) => BlocProvider<ManualBloc>(
            create: (context) => ManualBloc(
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
              account: account,
            ),
            child: const Manual(),
          ),
        );
      case authRoute:
        return CupertinoPageRoute(
          builder: (_) => BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              localRepositoryImpl: context.read<LocalRepositoryImpl>(),
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
