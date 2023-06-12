import 'package:flutter/material.dart' hide Router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/routing/navigation_service.dart';

import 'routing/router.dart';

class OtpManager extends HookWidget {
  const OtpManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpManagerBloc, OtpManagerState>(
        builder: (context, state) {
      return MaterialApp(
        title: 'OTP Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            titleMedium: GoogleFonts.roboto(color: Colors.white),
            titleLarge: GoogleFonts.roboto(),
          ),
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
        ),
        themeMode: state.darkTheme ? ThemeMode.dark : ThemeMode.light,
        onGenerateRoute: Router.generateRoute,
        initialRoute: state.initialRoute,
        navigatorKey: NavigationService().navigatorKey,
      );
    });
  }
}
