import 'package:flutter/material.dart' hide Router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/theme/color_schema.g.dart';
import 'package:otp_manager/utils/enum/theme_mode.dart' as otp_manager;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'routing/router.dart';

class OtpManager extends HookWidget {
  const OtpManager({super.key});

  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpManagerBloc, OtpManagerState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'OTP Manager',
          theme: _buildTheme(lightColorScheme),
          darkTheme: _buildTheme(
            state.blackTheme ? blackColorScheme : darkColorScheme,
          ),
          themeMode: switch (state.themeMode) {
            otp_manager.ThemeMode.light => ThemeMode.light,
            otp_manager.ThemeMode.dark => ThemeMode.dark,
            otp_manager.ThemeMode.system => ThemeMode.system,
          },
          onGenerateRoute: Router.generateRoute,
          initialRoute: state.initialRoute,
          navigatorKey: getIt<GlobalKey<NavigatorState>>(),
          scaffoldMessengerKey: getIt<GlobalKey<ScaffoldMessengerState>>(),
        );
      },
    );
  }
}
