import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import "../utils/pin.dart";
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
    final pinTextFieldController = useTextEditingController();
    final errorController = useStreamController<ErrorAnimationType>();

    useEffect(() {
      _authenticate().then((auth) {
        if (auth) context.read<AuthBloc>().add(Authenticated());
      });

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentication"),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.message != "") {
            showSnackBar(context: context, msg: state.message);
          } else if (state.isError) {
            pinTextFieldController.clear();
            errorController.add(ErrorAnimationType.shake);
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: pin(
                context: context,
                onCompleted: (value) =>
                    context.read<AuthBloc>().add(PinSubmit(pin: value)),
                textFieldController: pinTextFieldController,
                errorController: errorController,
              ),
            ),
          );
        },
      ),
    );
  }
}
