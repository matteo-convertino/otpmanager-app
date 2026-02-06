import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_bloc.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/screens/unlock_shared_account.dart';

void showOtpManagerUnlockSharedAccountModal({
  required BuildContext context,
  required int accountId,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext _) {
      return BlocProvider<UnlockSharedAccountBloc>(
        create: (_) => getIt<UnlockSharedAccountBloc>(param1: accountId),
        child: const UnlockSharedAccount(),
      );
    },
  );
}
