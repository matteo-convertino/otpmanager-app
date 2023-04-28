import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../main.dart' show objectBox;
import '../models/user.dart';
import "../utils/pin.dart";
import '../utils/toast.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key, required this.account}) : super(key: key);

  final Account account;

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _auth = LocalAuthentication();
  final TextEditingController _pinTextFieldController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  int _attempts = 3;
  late User _user;

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
  void initState() {
    super.initState();
    _user = objectBox.store.box<User>().getAll()[0];
    _authenticate().then((auth) {
      if (auth) {
        NavigationService().replaceScreen(
          manualRoute,
          arguments: {
            "account": widget.account,
            "auth": true,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentication"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: pin(
            context: context,
            onCompleted: (v) {
              if (v == _user.pin) {
                NavigationService().replaceScreen(
                  manualRoute,
                  arguments: {
                    "account": widget.account,
                    "auth": true,
                  },
                );
              } else {
                setState(() => _attempts--);

                _errorController.add(ErrorAnimationType.shake);
                _pinTextFieldController.clear();

                if (_attempts == 0) {
                  showToast("You used too many attempts try again");
                  NavigationService().resetToScreen(homeRoute);
                }
              }
            },
            textFieldController: _pinTextFieldController,
            errorController: _errorController,
          ),
        ),
      ),
    );
  }
}
