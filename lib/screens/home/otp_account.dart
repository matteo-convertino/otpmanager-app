import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart'
    hide CustomSlidableAction;
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_event.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_bloc.dart';
import 'package:otp_manager/domain/nextcloud_service.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/interface/shared_account_repository.dart';
import 'package:otp_manager/screens/unlock_shared_account.dart';
import 'package:otp_manager/utils/custom_circular_countdown_timer.dart';
import 'package:otp_manager/utils/custom_slidable_action.dart';
import 'package:otp_manager/utils/simple_icons.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/otp_account/otp_account_state.dart';
import '../../bloc/otp_manager/otp_manager_bloc.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';
import '../../utils/delete_modal.dart';
import '../../utils/qr_code_modal.dart';
import '../../utils/show_snackbar.dart';
import '../../utils/tooltip.dart';

class OtpAccount extends HookWidget {
  OtpAccount({Key? key, required this.account}) : super(key: key);

  final dynamic account; // Account | SharedAccount

  final NavigationService _navigationService = NavigationService();

  void _showUnlockSharedAccountModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext _) {
        return BlocProvider<UnlockSharedAccountBloc>(
          create: (_) => UnlockSharedAccountBloc(
            nextcloudService: context.read<NextcloudService>(),
            sharedAccountRepository: context.read<SharedAccountRepository>(),
            accountId: account.nextcloudAccountId,
            homeBloc: context.read<HomeBloc>(),
          ),
          child: const UnlockSharedAccount(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<OtpAccountBloc>().add(GenerateOtpCode(account: account));
      return null;
    }, []);

    useEffect(() {
      // account counter may have changed after sync -> regenerate code
      if (account.type.toLowerCase() == "hotp") {
        context.read<OtpAccountBloc>().add(GenerateOtpCode(account: account));
      }
      return null;
    });

    return BlocBuilder<OtpAccountBloc, OtpAccountState>(
      builder: (otpAccountContext, otpAccountState) {
        return BlocBuilder<OtpManagerBloc, OtpManagerState>(
          builder: (otpManagerContext, otpManagerState) {
            return InkWell(
              onTap: () {
                if (account is SharedAccount && !account.unlocked) {
                  _showUnlockSharedAccountModal(otpManagerContext);
                } else if (account.type == "hotp" && account.counter < 0) {
                  otpManagerContext
                      .read<OtpAccountBloc>()
                      .add(IncrementCounter(account: account));
                } else if (otpManagerState.copyWithTap) {
                  Clipboard.setData(
                      ClipboardData(text: otpAccountState.otpCode!));
                  showSnackBar(
                      context: otpManagerContext,
                      msg: "${account.type.toUpperCase()} code copied");
                } else {
                  _navigationService.navigateTo(
                    accountDetailsRoute,
                    arguments: account,
                  );
                }
              },
              child: Slidable(
                closeOnScroll: true,
                endActionPane: ActionPane(
                  extentRatio:
                      account is Account || account.unlocked ? 0.75 : 0.5,
                  motion: const ScrollMotion(),
                  children: [
                    CustomSlidableAction(
                      label: "Edit",
                      icon: Icons.edit,
                      padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                      backgroundColor: Colors.blue,
                      border: BorderRadius.circular(10.0),
                      onPressed: () => _navigationService.navigateTo(
                        manualRoute,
                        arguments: {"account": account},
                      ),
                    ),
                    if (account is Account ||
                        (account is SharedAccount && account.unlocked))
                      CustomSlidableAction(
                        label: "QR",
                        icon: Icons.qr_code,
                        padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                        backgroundColor: Colors.grey,
                        border: BorderRadius.circular(10.0),
                        onPressed: () =>
                            showQrCodeModal(otpManagerContext, account),
                      ),
                    CustomSlidableAction(
                      label: "Delete",
                      icon: Icons.delete,
                      padding: const EdgeInsets.fromLTRB(0, 10, 7, 10),
                      backgroundColor: Colors.red,
                      border: BorderRadius.circular(10.0),
                      onPressed: () => showDeleteModal(
                          otpManagerContext,
                          account,
                          () => otpManagerContext
                              .read<HomeBloc>()
                              .add(DeleteAccount(account: account))),
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
                    contentPadding: const EdgeInsets.all(0.0),
                    leading: SizedBox(
                      height: 40,
                      width: 40,
                      child: simpleIcons[account.iconKey] ??
                          simpleIcons['default'],
                    ),
                    title: Text(
                      account.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.issuer ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Text(
                                  otpAccountState.otpCode ??
                                      "- " * account.digits!,
                                  style: TextStyle(
                                    fontSize: otpAccountState.otpCode == null
                                        ? 28
                                        : otpAccountState.otpCode!
                                                .startsWith("C")
                                            ? 14
                                            : 28,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              if ((account is Account &&
                                      account.type == "totp") ||
                                  (account is SharedAccount &&
                                      account.unlocked &&
                                      account.type == "totp"))
                                CustomCircularCountDownTimer(
                                  period: account.period!,
                                  callback: () => otpManagerContext
                                      .read<OtpAccountBloc>()
                                      .add(GenerateOtpCode(account: account)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (account.toUpdate == true ||
                            (account is Account && account.isNew))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: tooltip(
                              "Have to be synchronised",
                              const Icon(
                                Icons.sync,
                                size: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        if (account is SharedAccount && !account.unlocked)
                          IconButton(
                            icon: const Icon(Icons.lock_open),
                            onPressed: () => _showUnlockSharedAccountModal(
                                otpManagerContext),
                          ),
                        if (account.type == "hotp")
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
                            onPressed: () => _navigationService.navigateTo(
                              accountDetailsRoute,
                              arguments: account,
                            ),
                          )
                        else if (otpAccountState.otpCode != null)
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: otpAccountState.otpCode!));
                              showSnackBar(
                                  context: otpManagerContext,
                                  msg:
                                      "${account.type.toUpperCase()} code copied");
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
