import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/di/injection.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../bloc/otp_account/otp_account_bloc.dart';
import '../../bloc/otp_accounts_timer/otp_accounts_timer_cubit.dart';
import 'otp_account/otp_account.dart';

class OtpAccountsList extends StatelessWidget {
  const OtpAccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final timerCubit = context.read<OtpAccountsTimerCubit>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return ReorderableListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: state.accounts.length,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var account = state.accounts[index];

            return BlocProvider<OtpAccountBloc>(
              key: ValueKey(account.encryptedSecret),
              create: (context) => getIt<OtpAccountBloc>(),
              child: OtpAccount(account: account),
            );
          },
          proxyDecorator: (child, index, animation) {
            return BlocProvider.value(
              value: timerCubit,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final animValue = Curves.easeInOut.transform(animation.value);
                  final elevation = lerpDouble(0, 6, animValue)!;

                  return Material(elevation: elevation, child: child);
                },
                child: child,
              ),
            );
          },
          onReorderItem: (oldIndex, newIndex) => context.read<HomeBloc>().add(
            Reorder(oldIndex: oldIndex, newIndex: newIndex),
          ),
        );
      },
    );
  }
}
