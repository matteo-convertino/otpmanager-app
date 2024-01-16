import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/screens/home/empty_data.dart';
import 'package:otp_manager/screens/home/otp_accounts_list.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../utils/arrow_painter.dart';
import '../../utils/show_snackbar.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.syncError != "") {
          showSnackBar(context: context, msg: state.syncError);
        }
        if (state.accountDeleted != "") {
          showSnackBar(context: context, msg: state.accountDeleted);
        }
      },
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (state.isGuest) ...[
              Container(
                width: double.infinity,
                height: 35,
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
                        "You are are using the test (offline) mode",
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
            ],
            if (state.accounts.isEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: ArrowPainter(),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  0, state.password == "" || state.isGuest ? 35 : 0, 0, 0),
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<HomeBloc>().add(NextcloudSync()),
                child: state.accounts.isEmpty
                    ? const EmptyData()
                    : const OtpAccountsList(),
              ),
            )
          ],
        );
      },
    );
  }
}
