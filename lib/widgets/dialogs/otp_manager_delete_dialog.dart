import 'package:flutter/material.dart';

void showOtpManagerDeleteDialog(
  BuildContext context, {
  required dynamic account,
  VoidCallback? onPressed,
}) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text(
      "Remove ${account.issuer != "" ? '${account.issuer} (${account.name})' : account.name}",
    ),
    content: const Text('Are you sure that you want to remove this account?'),
    actions: [
      TextButton(
        child: const Text('No'),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(onPressed: onPressed, child: const Text('Yes')),
    ],
  ),
);
