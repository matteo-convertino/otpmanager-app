import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_bloc.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../bloc/unlock_shared_account/unlock_shared_account_event.dart';
import '../widgets/otp_manager_auth_input.dart';

class UnlockSharedAccount extends HookWidget {
  const UnlockSharedAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final enabled = useState(true);

    return BlocConsumer<UnlockSharedAccountBloc, UnlockSharedAccountState>(
      listener: (context, state) {
        if (state.attempts == 0) {
          getIt<SnackbarService>().showMessage(
            "Too many attempts. Wait 5 seconds to try again.",
          );
          enabled.value = false;

          Timer(const Duration(seconds: 5), () {
            enabled.value = true;
          });
        }
      },
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
              child: Icon(Icons.lock_open, size: 100, color: Colors.blue),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: OtpManagerAuthInput(
                    label: "Shared Password",
                    helper:
                        "Insert the password that was used to share this account",
                    onChanged: (value) => context
                        .read<UnlockSharedAccountBloc>()
                        .add(PasswordChanged(password: value)),
                    onSubmit: () => context.read<UnlockSharedAccountBloc>().add(
                      PasswordSubmit(),
                    ),
                    enabled: enabled.value,
                    errorMsg: state.errorMsg,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
