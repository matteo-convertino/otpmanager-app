import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../bloc/account_details/account_details_event.dart';
import '../routing/constants.dart';
import '../routing/navigation_service.dart';
import '../widgets/dialogs/otp_manager_delete_dialog.dart';

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key});

  ListTile accountDetail(String title, String trailingText) {
    return ListTile(
      title: Text(title),
      trailing: SizedBox(
        width: 200,
        child: Text(
          trailingText,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account details'),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple),
            onPressed: () {
              getIt<NavigationService>().navigateTo(
                manualRoute,
                arguments: {
                  'account': context.read<AccountDetailsBloc>().state.account,
                },
              );
            },
          ),
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.trashSimple),
            onPressed: () {
              showOtpManagerDeleteDialog(
                context,
                account: context.read<AccountDetailsBloc>().state.account,
                onPressed: () =>
                    context.read<AccountDetailsBloc>().add(DeleteAccount()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountDetailsBloc, AccountDetailsState>(
        builder: (context, state) {
          return Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    accountDetail('Name', state.account.name),
                    accountDetail('Issuer', state.account.issuer ?? ''),
                    if (state.account.type == 'totp')
                      accountDetail('Period', '${state.account.period}s'),
                    accountDetail('Digits', state.account.digits.toString()),
                    accountDetail(
                      'Algorithm',
                      state.account.algorithm.toString().split('.')[1],
                    ),
                    accountDetail('Type', state.account.type.toUpperCase()),
                    if (state.account.type == 'hotp')
                      accountDetail(
                        'Counter',
                        state.account.counter != null
                            ? state.account.counter.toString()
                            : '',
                      ),
                    if (state.account is SharedAccount) ...[
                      accountDetail(
                        'Expired At',
                        state.account.expiredAt == null
                            ? 'Never expires'
                            : DateFormat(
                                'yyyy-MM-dd',
                              ).format(state.account.expiredAt),
                      ),
                    ],
                  ],
                ).toList(),
              ),
              if (state.account is SharedAccount) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const PhosphorIcon(PhosphorIconsRegular.user),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: Image.network(
                              '${state.serverUrl}/avatar/${state.account.sharerUserId}/64',
                              fit: BoxFit.fill,
                              height: 50.0,
                              width: 50.0,
                              errorBuilder: (_, _, _) =>
                                  const PhosphorIcon(PhosphorIconsRegular.user),
                            ),
                          ),
                        ],
                      ),
                      const PhosphorIcon(PhosphorIconsRegular.link),
                    ],
                  ),
                ),
                Text(
                  'Shared by ${state.account.sharerUserId}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    //color: Colors.grey,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
