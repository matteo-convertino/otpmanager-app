import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String text, {Toast toastLength = Toast.LENGTH_LONG}) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: toastLength,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16,
  );
}
