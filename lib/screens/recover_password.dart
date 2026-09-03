import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_bloc.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_event.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/otp_manager_auth_input.dart';

class RecoverPassword extends HookWidget {
  const RecoverPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = useState(true);

    Widget buildRequirement({required bool value, required String label}) {
      return RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            WidgetSpan(
              child: value
                  ? PhosphorIcon(
                      PhosphorIconsRegular.checkCircle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : PhosphorIcon(
                      PhosphorIconsRegular.xCircle,
                      color: Theme.of(context).colorScheme.error,
                    ),

              alignment: .middle,
            ),
            TextSpan(text: ' $label'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recover Password')),
      body: BlocConsumer<RecoverPasswordBloc, RecoverPasswordState>(
        listener: (context, state) {
          if (state.attempts == 0) {
            getIt<SnackbarService>().showMessage(
              'Too many attempts. Wait 5 seconds to try again.',
            );
            enabled.value = false;

            Timer(const Duration(seconds: 5), () => enabled.value = true);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const .symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              spacing: 16,
              children: [
                OtpManagerAuthInput(
                  label: 'New Password',
                  onChanged: (value) => context.read<RecoverPasswordBloc>().add(
                    NewPasswordChanged(newPassword: value),
                  ),
                  enabled: enabled.value,
                  errorMsg: state.errorMsg,
                ),
                AnimatedCrossFade(
                  crossFadeState: state.passwordRequirements.allSatisfied()
                      ? .showFirst
                      : .showSecond,
                  duration: const Duration(milliseconds: 200),
                  firstChild: OtpManagerAuthInput(
                    label: 'Confirm Password',
                    onChanged: (value) => context
                        .read<RecoverPasswordBloc>()
                        .add(OldPasswordChanged(oldPassword: value)),
                    enabled: enabled.value,
                    errorMsg: state.errorMsg,
                  ),
                  secondChild: Column(
                    crossAxisAlignment: .start,
                    spacing: 4,
                    children: [
                      buildRequirement(
                        value: state.passwordRequirements.length,
                        label: 'Length greater than 5 character',
                      ),
                      buildRequirement(
                        value: state.passwordRequirements.number,
                        label: 'Includes number',
                      ),
                      buildRequirement(
                        value: state.passwordRequirements.lowercase,
                        label: 'Includes lowercase letter',
                      ),
                      buildRequirement(
                        value: state.passwordRequirements.uppercase,
                        label: 'Includes uppercase letter',
                      ),
                      buildRequirement(
                        value: state.passwordRequirements.specialChar,
                        label: 'Includes special symbol',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const PhosphorIcon(PhosphorIconsRegular.key),
        onPressed: () =>
            context.read<RecoverPasswordBloc>().add(RecoverPasswordSubmit()),
      ),
    );
  }
}
