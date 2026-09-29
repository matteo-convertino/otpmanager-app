import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/login/login_bloc.dart';
import 'package:otp_manager/bloc/manual/manual_bloc.dart';
import 'package:otp_manager/bloc/otp_accounts_timer/otp_accounts_timer_cubit.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/screens/recover_password.dart';

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
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<HomeBloc>()),
              BlocProvider(create: (_) => OtpAccountsTimerCubit()),
            ],
            child: const Home(),
          ),
        );
      case importRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => const Import(),
        );
      case settingsRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<SettingsBloc>(),
            child: const Settings(),
          ),
        );
      case qrCodeScannerRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<QrCodeScannerBloc>(),
            child: const QrCodeScanner(),
          ),
        );
      case accountDetailsRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<AccountDetailsBloc>(param1: settings.arguments),
            child: const AccountDetails(),
          ),
        );
      case loginRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginBloc>(),
            child: const Login(),
          ),
        );
      case webViewerRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<WebViewerBloc>(param1: settings.arguments),
            child: const WebViewer(),
          ),
        );
      case manualRoute:
        Map arguments = settings.arguments as Map;
        var account = arguments['account'];

        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ManualBloc>(param1: account),
            child: const Manual(),
          ),
        );
      case authRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(param1: settings.arguments ?? false),
            child: const Auth(),
          ),
        );
      case recoverPasswordRoute:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<RecoverPasswordBloc>(),
            child: const RecoverPassword(),
          ),
        );
      default:
        return CupertinoPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
