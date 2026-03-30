import 'package:flutter/material.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void showOtpManagerRecoverPasswordDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Forgotten your password?'),
    content: const Text.rich(
      TextSpan(
        text:
            'If you have forgotten the password you created on the'
            ' Nextcloud web extension, you can change it by continuing.\n\n',
        children: [
          WidgetSpan(
            child: PhosphorIcon(PhosphorIconsRegular.warning, size: 16),
            alignment: .middle,
          ),
          TextSpan(
            text:
                ' Please note that once you have changed it, you will be asked '
                'to enter it in the app straight away ',
          ),
          TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold),
            text: '(make a note of it somewhere!).',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        child: const Text('Close'),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: const Text('Recover password'),
        onPressed: () =>
            getIt<NavigationService>().navigateTo(authRoute, arguments: true),
      ),
    ],
  ),
);
