import 'package:flutter/material.dart';

class OtpManagerTooltip extends StatelessWidget {
  const OtpManagerTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 2),
      verticalOffset: 20,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(color: Colors.white),
      child: child,
    );
  }
}
