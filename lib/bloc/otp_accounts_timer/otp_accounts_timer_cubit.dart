import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_accounts_timer/otp_accounts_timer_state.dart';

class OtpAccountsTimerCubit extends Cubit<OtpAccountsTimerState> {
  OtpAccountsTimerCubit() : super(_currentState()) {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => emit(_currentState()),
    );
  }

  late final Timer _timer;

  static OtpAccountsTimerState _currentState() =>
      OtpAccountsTimerState.fromTimestamp(
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond,
      );

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
