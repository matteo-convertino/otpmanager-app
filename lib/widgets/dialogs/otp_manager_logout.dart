import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_event.dart';

void showOtpManagerLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Logout'),
      content: const Text(
        'Are you sure that you want to logout from your Nextcloud account?',
      ),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () => context.read<OtpManagerBloc>().add(Logout()),
        ),
      ],
    ),
  );
}
