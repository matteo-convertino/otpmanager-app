import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OtpCountdownClockScope extends InheritedWidget {
  const OtpCountdownClockScope({
    super.key,
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  static Animation<double> of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<OtpCountdownClockScope>();
    assert(scope != null, 'No OtpCountdownClockScope found in context');
    return scope!.animation;
  }

  @override
  bool updateShouldNotify(OtpCountdownClockScope oldWidget) =>
      animation != oldWidget.animation;
}

class OtpManagerCircularCountDownTimer extends HookWidget {
  const OtpManagerCircularCountDownTimer({
    super.key,
    required this.period,
    required this.callback,
  });

  final int period;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final clock = OtpCountdownClockScope.of(context);
    useAnimation(clock);

    final periodInMilliseconds = period * Duration.millisecondsPerSecond;
    final now = DateTime.now().millisecondsSinceEpoch;
    final periodIndex = now ~/ periodInMilliseconds;
    final remainingMilliseconds =
        periodInMilliseconds - (now % periodInMilliseconds);
    final animationValue = remainingMilliseconds / periodInMilliseconds;
    final callbackRef = useRef(callback)..value = callback;
    final previousPeriodIndex = useRef(periodIndex);

    useEffect(() {
      if (previousPeriodIndex.value != periodIndex) {
        previousPeriodIndex.value = periodIndex;
        callbackRef.value();
      }
      return null;
    }, [periodIndex]);

    return SizedBox(
      width: 21,
      height: 21,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CustomTimerPainter(
                animation: AlwaysStoppedAnimation(animationValue),
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
              '${(remainingMilliseconds / Duration.millisecondsPerSecond).ceil()}',
              style: const TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
