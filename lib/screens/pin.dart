import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/utils/toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../main.dart' show objectBox;
import '../models/user.dart';
import '../object_box/objectbox.g.dart';
import "../routing/constants.dart";
import "../utils/pin.dart";

class Pin extends StatefulWidget {
  Pin({Key? key, required this.title, required this.toEdit, this.newPassword})
      : super(key: key);

  final String title;
  final bool toEdit;
  String? newPassword;

  @override
  State<Pin> createState() => _PinState();
}

class _PinState extends State<Pin> {
  final TextEditingController _pinTextFieldController = TextEditingController();

  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();

  late User _user;
  int _attempts = 3;
  final Box<User> _userBox = objectBox.store.box<User>();

  void _error() {
    setState(() => _attempts--);

    _errorController.add(ErrorAnimationType.shake);
    _pinTextFieldController.clear();

    if (_attempts == 0) {
      showToast("You used too many attempts try again");
      NavigationService().resetToScreen(homeRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    _user = _userBox.getAll()[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: pin(
            context: context,
            onCompleted: (v) {
              if (widget.newPassword != null && widget.newPassword != "") {
                if (v == widget.newPassword) {
                  _user.pin = v;
                  _userBox.put(_user);
                  showToast("Pin successfully updated");
                  NavigationService().resetToScreen(homeRoute);
                } else {
                  _error();
                }
              } else if (widget.toEdit) {
                if (v == _user.pin) {
                  NavigationService().replaceScreen(pinRoute, arguments: {
                    "toEdit": false,
                  });
                } else {
                  _error();
                }
              } else {
                if (RegExp(r'^\d+$').hasMatch(v)) {
                  NavigationService().replaceScreen(pinRoute, arguments: {
                    "newPassword": v,
                  });
                } else {
                  _error();
                  showToast("You can insert only digits");
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
