import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:otp_manager/bloc/home/home_bloc.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_delete_dialog.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_qr_code_dialog.dart';
import 'package:otp_manager/widgets/otp_manager_slidable_action.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class OtpAccountSlidable extends StatelessWidget {
  const OtpAccountSlidable({
    super.key,
    required this.account,
    required this.showQrAction,
    required this.child,
  });

  final dynamic account; // Account | SharedAccount
  final bool showQrAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        extentRatio: showQrAction ? 0.80 : 0.5,
        motion: const ScrollMotion(),
        children: [
          OtpManagerSlidableAction(
            label: 'Edit',
            icon: const Icon(PhosphorIconsRegular.pencilSimple),
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () => getIt<NavigationService>().navigateTo(
              manualRoute,
              arguments: {'account': account},
            ),
          ),
          if (showQrAction)
            OtpManagerSlidableAction(
              label: 'QR',
              icon: const Icon(PhosphorIconsRegular.qrCode),
              backgroundColor: Colors.grey,
              onPressed: () => showOtpManagerQrCodeDialog(context, account),
            ),
          OtpManagerSlidableAction(
            label: 'Delete',
            icon: const Icon(PhosphorIconsRegular.trashSimple),
            backgroundColor: Colors.red,
            onPressed: () => showOtpManagerDeleteDialog(
              context,
              account: account,
              onPressed: () =>
                  context.read<HomeBloc>().add(DeleteAccount(account: account)),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}
