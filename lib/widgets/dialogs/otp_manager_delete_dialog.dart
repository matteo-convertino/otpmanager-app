import 'package:flutter/material.dart';

void showOtpManagerDeleteModal(
  BuildContext context,
  dynamic account,
  Function onPressed,
) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text(
      "Remove ${account.issuer != "" ? '${account.issuer} (${account.name})' : account.name}",
    ),
    content: const Text('Are you sure that you want to remove this account?'),
    actions: [
      TextButton(
        child: const Text("No"),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(child: const Text("Yes"), onPressed: () => onPressed()),
    ],
  ),
);
