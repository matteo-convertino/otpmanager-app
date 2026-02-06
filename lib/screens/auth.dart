import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import "../widgets/otp_manager_auth_input.dart";

class Auth extends HookWidget {
  Auth({Key? key}) : super(key: key);

  final _auth = LocalAuthentication();

  Future<bool> _hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _authenticate() async {
    final isAvailable = await _hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan Fingerprint to Authenticate',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = useState(true);

    return Scaffold(
      appBar: AppBar(title: const Text("Authentication")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.attempts == 0) {
            getIt<SnackbarService>().showMessage(
              "Too many attempts. Wait 5 seconds to try again.",
            );
            enabled.value = false;

            Timer(const Duration(seconds: 5), () {
              enabled.value = true;
            });
          }
          if (state.canShowFingerAuth) {
            _authenticate().then((auth) {
              if (auth) context.read<AuthBloc>().add(Authenticated());
            });
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 50),
                    child: OtpManagerAuthInput(
                      label: "Password",
                      onChanged: (value) => context.read<AuthBloc>().add(
                        PasswordChanged(password: value),
                      ),
                      onSubmit: () =>
                          context.read<AuthBloc>().add(PasswordSubmit()),
                      enabled: enabled.value,
                      errorMsg: state.message,
                    ),
                  ),
                  if (!state.isUserPasswordEmpty)
                    IconButton(
                      onPressed: () =>
                          context.read<AuthBloc>().add(ShowFingerAuth()),
                      icon: Icon(
                        Icons.fingerprint,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
