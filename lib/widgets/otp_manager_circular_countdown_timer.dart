import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_accounts_timer/otp_accounts_timer_cubit.dart';
import 'package:otp_manager/bloc/otp_accounts_timer/otp_accounts_timer_state.dart';

class OtpManagerCircularCountDownTimer extends StatelessWidget {
  const OtpManagerCircularCountDownTimer({
    super.key,
    required this.period,
    required this.callback,
  });

  final int period;
  final VoidCallback callback;

  int _remainingSeconds(OtpAccountsTimerState state) => switch (period) {
    45 => state.remaining45,
    60 => state.remaining60,
    _ => state.remaining30,
  };

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = context.select(
      (OtpAccountsTimerCubit cubit) => _remainingSeconds(cubit.state),
    );

    return BlocListener<OtpAccountsTimerCubit, OtpAccountsTimerState>(
      listenWhen: (previous, current) =>
          _remainingSeconds(current) > _remainingSeconds(previous),
      listener: (_, _) => callback(),
      child: SizedBox(
        width: 21,
        height: 21,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: CustomTimerPainter(
                  animation: AlwaysStoppedAnimation(remainingSeconds / period),
                  fillColor: Theme.of(context).colorScheme.primary,
                  ringColor: Theme.of(context).focusColor,
                  strokeWidth: 1.5,
                  strokeCap: StrokeCap.butt,
                  isReverse: true,
                  isReverseAnimation: false,
                ),
              ),
            ),
            Align(
              child: Text(
                '$remainingSeconds',
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
