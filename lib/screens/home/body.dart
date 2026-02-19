import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/screens/home/empty_data.dart';
import 'package:otp_manager/screens/home/otp_accounts_list.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../widgets/otp_manager_arrow_painter.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (state.isGuest) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 35,
                child: Container(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromRGBO(0, 185, 255, 1)
                      : Theme.of(context).secondaryHeaderColor,
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.amber),
                        Text(
                          'You are are using the test (offline) mode',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                        const Icon(Icons.warning_amber, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (state.accounts.isEmpty && state.searchBarValue.isEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: CustomPaint(painter: OtpManagerArrowPainter()),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                state.password.isEmpty || state.isGuest ? 35 : 0,
                0,
                0,
              ),
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<HomeBloc>().add(NextcloudSync()),
                child: state.accounts.isEmpty
                    ? (state.searchBarValue.isEmpty
                          ? const EmptyData(
                              imageName: 'no_accounts',
                              title: 'Add your first account',
                              description:
                                  'You currently have no account. Synchronise by dragging down or create a new one below.',
                            )
                          : EmptyData(
                              imageName: 'no_results',
                              title: 'No accounts for: ${state.searchBarValue}',
                              description: '',
                            ))
                    : const OtpAccountsList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
