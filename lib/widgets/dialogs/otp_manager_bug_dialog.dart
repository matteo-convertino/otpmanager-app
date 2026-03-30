import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';

void showOtpManagerBugDialog(BuildContext context) => showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Bug Report'),
    content: Text.rich(
      TextSpan(
        text:
            'If you have found a bug and want to report '
            'it to the developer, contact him via email on ',
        children: [
          TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            text: 'matteo@convertino.cloud',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.read<SettingsBloc>().add(
                  const OpenLink(url: 'mailto:matteo@convertino.cloud'),
                );
              },
          ),
          const TextSpan(text: ' or open an issue on '),
          TextSpan(
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
            text: 'github',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.read<SettingsBloc>().add(
                  const OpenLink(
                    url:
                        'https://github.com/matteo-convertino/otpmanager-app/issues',
                  ),
                );
              },
          ),
          const TextSpan(
            text:
                ', attaching the log'
                ' file that you can download from here.',
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
        child: const Text('Download Log'),
        onPressed: () => context.read<SettingsBloc>().add(SaveLog()),
      ),
    ],
  ),
);
