import 'package:flutter/material.dart';

void showSnackBar({required BuildContext context, required String msg}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
