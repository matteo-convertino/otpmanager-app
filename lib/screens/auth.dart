import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/auth/auth_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/otp_manager_auth_input.dart';
import '../widgets/otp_manager_unlock_lottie.dart';

class Auth extends HookWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = useState(true);

    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.attempts == 0) {
            getIt<SnackbarService>().showMessage(
              'Too many attempts. Wait 5 seconds to try again.',
            );
            enabled.value = false;

            Timer(const Duration(seconds: 5), () => enabled.value = true);
          }

          if (state.isCorrectPassword) enabled.value = false;
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: .stretch,
            children: [
              OtpManagerUnlockLottie(
                isUnlocked: state.isCorrectPassword,
                onEnd: () {
                  if (enabled.value) return;

                  getIt<NavigationService>().replaceScreen(
                    state.isRecoveringPassword
                        ? recoverPasswordRoute
                        : homeRoute,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 50),
                child: state.isRecoveringPassword
                    ? const Text(
                        'Please verify your identity before changing your password',
                        textAlign: .center,
                      )
                    : OtpManagerAuthInput(
                        label: 'Password',
                        onChanged: (value) => context.read<AuthBloc>().add(
                          PasswordChanged(password: value),
                        ),
                        onSubmit: () =>
                            context.read<AuthBloc>().add(PasswordSubmit()),
                        enabled: enabled.value,
                        errorMsg: state.message,
                      ),
              ),
              if (state.canShowDeviceAuth)
                IconButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(ShowDeviceAuth()),
                  icon: PhosphorIcon(
                    state.canShowFingerAuth
                        ? PhosphorIconsRegular.fingerprint
                        : PhosphorIconsRegular.numpad,
                    size: state.canShowFingerAuth ? 60 : 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
