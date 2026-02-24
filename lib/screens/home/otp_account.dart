import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart'
    hide CustomSlidableAction;
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_event.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';
import 'package:otp_manager/widgets/otp_manager_circular_countdown_timer.dart';
import 'package:otp_manager/widgets/otp_manager_slidable_action.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/otp_account/otp_account_state.dart';
import '../../bloc/otp_manager/otp_manager_bloc.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';
import '../../widgets/dialogs/otp_manager_delete_dialog.dart';
import '../../widgets/dialogs/otp_manager_qr_code_dialog.dart';
import '../../widgets/dialogs/otp_manager_unlock_shared_account_dialog.dart';
import '../../widgets/otp_manager_tooltip.dart';

class OtpAccount extends HookWidget {
  OtpAccount({super.key, required this.account});

  final dynamic account; // Account | SharedAccount

  final NavigationService navigationService = getIt<NavigationService>();

  @override
  Widget build(BuildContext context) {
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
      builder: (otpAccountContext, otpAccountState) {
        return BlocBuilder<OtpManagerBloc, OtpManagerState>(
          builder: (otpManagerContext, otpManagerState) {
            final isLockedSharedAccount =
                account is SharedAccount && !account.unlocked;

            final hotpInvalidCounter =
                account.type == OtpType.hotp.value && account.counter < 0;

            final showTimer =
                account.type == OtpType.totp.value && !isLockedSharedAccount;

            final showQrAction = !isLockedSharedAccount;

            final showSyncBadge =
                account.toUpdate == true ||
                (account is Account && account.isNew);

            return InkWell(
              onTap: () {
                if (isLockedSharedAccount) {
                  showOtpManagerUnlockSharedAccountModal(
                    context: otpManagerContext,
                    accountId: account.nextcloudAccountId,
                  );
                } else if (hotpInvalidCounter) {
                  otpManagerContext.read<OtpAccountBloc>().add(
                    IncrementCounter(account: account),
                  );
                } else if (otpManagerState.copyWithTap) {
                  Clipboard.setData(
                    ClipboardData(text: otpAccountState.otpCode!),
                  );
                  getIt<SnackbarService>().showMessage(
                    '${account.type.toUpperCase()} code copied',
                  );
                  return;
                } else {
                  navigationService.navigateTo(
                    accountDetailsRoute,
                    arguments: account,
                  );
                }
              },
              child: Slidable(
                closeOnScroll: true,
                endActionPane: ActionPane(
                  extentRatio: showQrAction ? 0.75 : 0.5,
                  motion: const ScrollMotion(),
                  children: [
                    OtpManagerSlidableAction(
                      label: 'Edit',
                      icon: Icons.edit,
                      padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                      backgroundColor: Colors.blue,
                      border: BorderRadius.circular(10.0),
                      onPressed: () => navigationService.navigateTo(
                        manualRoute,
                        arguments: {'account': account},
                      ),
                    ),
                    if (showQrAction)
                      OtpManagerSlidableAction(
                        label: 'QR',
                        icon: Icons.qr_code,
                        padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                        backgroundColor: Colors.grey,
                        border: BorderRadius.circular(10.0),
                        onPressed: () => showOtpManagerQrCodeDialog(
                          otpManagerContext,
                          account,
                        ),
                      ),
                    OtpManagerSlidableAction(
                      label: 'Delete',
                      icon: Icons.delete,
                      padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                      backgroundColor: Colors.red,
                      border: BorderRadius.circular(10.0),
                      onPressed: () => showOtpManagerDeleteDialog(
                        otpManagerContext,
                        account: account,
                        onPressed: () => otpManagerContext.read<HomeBloc>().add(
                          DeleteAccount(account: account),
                        ),
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    //vertical: 0.0,
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      height: 40,
                      width: 40,
                      child:
                          OtpIconsHelper.simpleIcons[account.iconKey] ??
                          OtpIconsHelper.simpleIcons['default'],
                    ),
                    title: Text(
                      account.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          account.issuer ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          spacing: 15,
                          children: [
                            Flexible(
                              child: Text(
                                otpAccountState.otpMessage ??
                                    otpAccountState.otpCode ??
                                    '- ' * account.digits!,
                                style: TextStyle(
                                  fontSize: otpAccountState.otpMessage == null
                                      ? 28
                                      : 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            if (showTimer)
                              OtpManagerCircularCountDownTimer(
                                period: account.period!,
                                callback: () => otpManagerContext
                                    .read<OtpAccountBloc>()
                                    .add(GenerateOtpCode(account: account)),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showSyncBadge)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: OtpManagerTooltip(
                              message: 'Have to be synchronised',
                              child: Icon(
                                Icons.sync,
                                size: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        if (isLockedSharedAccount)
                          IconButton(
                            icon: const Icon(Icons.lock_open),
                            onPressed: () =>
                                showOtpManagerUnlockSharedAccountModal(
                                  context: otpManagerContext,
                                  accountId: account.nextcloudAccountId,
                                ),
                          ),
                        if (account.type == OtpType.hotp.value)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: otpAccountState.disableIncrement
                                ? null
                                : () => otpManagerContext
                                      .read<OtpAccountBloc>()
                                      .add(IncrementCounter(account: account)),
                          ),
                        if (otpManagerState.copyWithTap)
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => navigationService.navigateTo(
                              accountDetailsRoute,
                              arguments: account,
                            ),
                          )
                        else if (otpAccountState.otpCode != null)
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: otpAccountState.otpCode!),
                              );
                              getIt<SnackbarService>().showMessage(
                                '${account.type.toUpperCase()} code copied',
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
