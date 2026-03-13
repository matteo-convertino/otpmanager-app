import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

class OtpManagerUnlockLottie extends HookWidget {
  const OtpManagerUnlockLottie({
    super.key,
    required this.isUnlocked,
    this.onEnd,
  });

  final bool isUnlocked;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController();

    useEffect(() {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) onEnd?.call();
      }

      controller.addStatusListener(listener);
      return () => controller.removeStatusListener(listener);
    }, [controller]);

    useEffect(() {
      if (!isUnlocked) {
        controller.animateTo(0.25, duration: const Duration(seconds: 1));
      } else {
        controller.animateTo(1.0, duration: const Duration(seconds: 2));
      }

      return null;
    }, [isUnlocked]);

    return Lottie.asset(
      'assets/lottie/unlock.json',
      controller: controller,
      width: 125,
    );
  }
}
