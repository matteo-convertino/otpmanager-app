import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_event.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_state.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';
import 'package:otp_manager/widgets/otp_manager_circular_countdown_timer.dart';

import 'otp_account_actions.dart';
import 'otp_account_code.dart';

class OtpAccountListTile extends HookWidget {
  const OtpAccountListTile({
    super.key,
    required this.account,
    required this.isLockedSharedAccount,
    required this.blurredCode,
  });

  final dynamic account; // Account | SharedAccount
  final bool isLockedSharedAccount;
  final ValueNotifier<bool> blurredCode;

  @override
  Widget build(BuildContext context) {
    final showTimer =
        account.type == OtpType.totp.value && !isLockedSharedAccount;

    final issuerNotEmpty = account.issuer != null && account.issuer.isNotEmpty;

    return BlocBuilder<OtpAccountBloc, OtpAccountState>(
      builder: (context, state) {
        return ListTile(
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
            issuerNotEmpty ? account.issuer : account.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14.5),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Text(
                issuerNotEmpty ? account.name : '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14.5, color: Colors.grey),
              ),

              Row(
                spacing: 15,
                children: [
                  Flexible(
                    child: OtpAccountCode(
                      account: account,
                      blurredCode: blurredCode,
                    ),
                  ),
                  if (showTimer)
                    OtpManagerCircularCountDownTimer(
                      period: account.period!,
                      callback: () => context.read<OtpAccountBloc>().add(
                        GenerateOtpCode(account: account),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: OtpAccountActions(
            account: account,
            isLockedSharedAccount: isLockedSharedAccount,
          ),
        );
      },
    );
  }
}
