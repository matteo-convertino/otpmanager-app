import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp_manager/utils/toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

PinCodeTextField pin({
  required BuildContext context,
  required void Function(String) onCompleted,
  required TextEditingController textFieldController,
  required StreamController<ErrorAnimationType> errorController,
}) {
  return PinCodeTextField(
    appContext: context,
    length: 6,
    obscureText: true,
    animationType: AnimationType.scale,
    pinTheme: PinTheme(
      shape: PinCodeFieldShape.underline,
      fieldWidth: 40,
      inactiveFillColor: Colors.transparent,
      inactiveColor: Colors.blueAccent,
      activeColor: Colors.blueAccent,
      selectedFillColor: Colors.transparent,
    ),
    autoFocus: true,
    cursorColor: Theme.of(context).primaryColor,
    errorAnimationController: errorController,
    controller: textFieldController,
    keyboardType: TextInputType.phone,
    onCompleted: onCompleted,
    onChanged: (value) {},
    pastedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
    autoDisposeControllers: false,
    beforeTextPaste: (text) {
      // check if copied text has only digits [0-9]
      if (RegExp(r'^\d+$').hasMatch(text!)) {
        return true;
      } else {
        showToast("You can paste only digits");
        return false;
      }
    },
  );
}
