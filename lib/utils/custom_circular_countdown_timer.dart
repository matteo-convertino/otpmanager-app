import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/count_down_controller_hook.dart';

class CustomCircularCountDownTimer extends HookWidget {
  CustomCircularCountDownTimer({Key? key, required this.period, required this.callback})
      : super(key: key);

  final int period;
  final Function callback;
  late final int initialDuration = (((DateTime.now().millisecondsSinceEpoch ~/ 1000).round()) %
      period);

  @override
  Widget build(BuildContext context) {
    final countDownController = useCountDownController();

    return CircularCountDownTimer(
      duration: period,
      initialDuration: initialDuration,
      controller: countDownController,
      width: 20,
      height: 20,
      ringColor: Theme.of(context).focusColor,
      fillColor: Theme.of(context).primaryColor,
      strokeWidth: 1.5,
      textStyle: const TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.w600,
      ),
      isReverse: true,
      isReverseAnimation: false,
      isTimerTextShown: true,
      autoStart: true,
      onComplete: () {
        callback();
        countDownController.restart();
      },
    );
  }
}
