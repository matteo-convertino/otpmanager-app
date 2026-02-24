import 'package:flutter/material.dart';
import 'package:otp_manager/utils/launch_url.dart';

void showOtpManagerSupportDialog(
  BuildContext context, {
  VoidCallback? onPressed,
}) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Become a Supporter'),
    content: const Text(
      'If OTP Manager is worth a cup of coffee ☕️ and helps you during the day, you can support it with a small donation (even \$1). It helps me maintain the app and build new features.',
    ),
    actions: [
      TextButton(
        child: const Text('Maybe later'),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        onPressed: () => customLaunchUrl('https://ko-fi.com/matteoconvertino'),
        child: const Text('I want to support'),
      ),
    ],
  ),
);
