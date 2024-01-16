import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';

import "../utils/auth_input.dart";
import '../utils/show_snackbar.dart';

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
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = useState(true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentication"),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.attempts == 0) {
            showSnackBar(
              context: context,
              msg: "Too many attempts. Wait 5 seconds to try again.",
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
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
                child: Icon(
                  Icons.lock,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: AuthInput(
                      onChanged: (value) => context
                          .read<AuthBloc>()
                          .add(PasswordChanged(password: value)),
                      onSubmit: () =>
                          context.read<AuthBloc>().add(PasswordSubmit()),
                      enabled: enabled.value,
                      errorMsg: state.message,
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
