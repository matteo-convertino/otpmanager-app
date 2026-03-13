import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_event.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/screens/home/otp_account/otp_account_list_tile.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';

import '../../../bloc/otp_account/otp_account_state.dart';
import '../../../bloc/otp_manager/otp_manager_bloc.dart';
import '../../../routing/constants.dart';
import '../../../routing/navigation_service.dart';
import '../../../widgets/dialogs/otp_manager_unlock_shared_account_dialog.dart';
import 'otp_account_slidable.dart';

class OtpAccount extends HookWidget {
  OtpAccount({super.key, required this.account});

  final dynamic account; // Account | SharedAccount

  final NavigationService navigationService = getIt<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final clickToRevealCodes = context.select(
      (OtpManagerBloc bloc) => bloc.state.clickToRevealCodes,
    );
    final copyWithTap = context.select(
      (OtpManagerBloc bloc) => bloc.state.copyWithTap,
    );

    final blurredCode = useState(clickToRevealCodes);

    useEffect(() {
      blurredCode.value = clickToRevealCodes;
      return null;
    }, [clickToRevealCodes]);

    useEffect(() {
      context.read<OtpAccountBloc>().add(GenerateOtpCode(account: account));
      return null;
    }, []);

    useEffect(() {
      // account counter may have changed after sync -> regenerate code
      if (account.type == OtpType.hotp.value) {
        context.read<OtpAccountBloc>().add(GenerateOtpCode(account: account));
      }
      return null;
    });

    return BlocBuilder<OtpAccountBloc, OtpAccountState>(
      builder: (context, state) {
        final isLockedSharedAccount =
            account is SharedAccount && !account.unlocked;

        final hotpInvalidCounter =
            account.type == OtpType.hotp.value && account.counter < 0;

        return InkWell(
          onTap: () {
            if (isLockedSharedAccount) {
              showOtpManagerUnlockSharedAccountModal(
                context: context,
                accountId: account.nextcloudAccountId,
              );
            } else if (hotpInvalidCounter) {
              context.read<OtpAccountBloc>().add(
                IncrementCounter(account: account),
              );
            } else if (copyWithTap) {
              if (clickToRevealCodes) {
                blurredCode.value = false;

                Future.delayed(
                  const Duration(seconds: 3),
                  () => blurredCode.value = true,
                );
              }

              Clipboard.setData(ClipboardData(text: state.otpCode!));
              getIt<SnackbarService>().showMessage(
                '${account.type.toUpperCase()} code copied',
              );
            } else {
              navigationService.navigateTo(
                accountDetailsRoute,
                arguments: account,
              );
            }
          },
          child: OtpAccountSlidable(
            account: account,
            showQrAction: !isLockedSharedAccount,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                //vertical: 0.0,
              ),
              child: OtpAccountListTile(
                account: account,
                blurredCode: blurredCode,
                isLockedSharedAccount: isLockedSharedAccount,
              ),
            ),
          ),
        );
      },
    );
  }
}
