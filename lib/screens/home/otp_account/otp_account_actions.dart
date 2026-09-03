import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_event.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_state.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_unlock_shared_account_dialog.dart';
import 'package:otp_manager/widgets/tooltip/otp_manager_tooltip.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class OtpAccountActions extends StatelessWidget {
  const OtpAccountActions({
    super.key,
    required this.account,
    required this.isLockedSharedAccount,
  });

  final dynamic account; // Account | SharedAccount
  final bool isLockedSharedAccount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OtpAccountBloc, OtpAccountState>(
      builder: (context, state) {
        final showSyncBadge =
            account.toUpdate || (account is Account && account.isNew);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSyncBadge)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OtpManagerTooltip(
                  message: 'Have to be synchronised',
                  child: PhosphorIcon(
                    PhosphorIconsRegular.arrowsClockwise,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            if (isLockedSharedAccount)
              IconButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.lockOpen),
                onPressed: () => showOtpManagerUnlockSharedAccountModal(
                  context: context,
                  accountId: account.nextcloudAccountId,
                ),
              ),
            if (account.type == OtpType.hotp.value)
              IconButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise),
                onPressed: state.disableIncrement
                    ? null
                    : () => context.read<OtpAccountBloc>().add(
                        IncrementCounter(account: account),
                      ),
              ),
            if (context.select((OtpManagerBloc bloc) => bloc.state.copyWithTap))
              IconButton(
                icon: const PhosphorIcon(
                  PhosphorIconsRegular.dotsThreeVertical,
                ),
                onPressed: () => getIt<NavigationService>().navigateTo(
                  accountDetailsRoute,
                  arguments: account,
                ),
              )
            else if (state.otpCode != null)
              IconButton(
                icon: const PhosphorIcon(PhosphorIconsRegular.copySimple),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: state.otpCode!));
                  getIt<SnackbarService>().showMessage(
                    '${account.type.toUpperCase()} code copied',
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
