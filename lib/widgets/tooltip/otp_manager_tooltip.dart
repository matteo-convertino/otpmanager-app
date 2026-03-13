import 'package:el_tooltip/el_tooltip.dart';
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
    return ElTooltip(
      timeout: const Duration(seconds: 2),
      appearAnimationDuration: const Duration(milliseconds: 50),
      disappearAnimationDuration: const Duration(milliseconds: 50),
      showModal: false,
      showChildAboveOverlay: false,
      position: .bottomCenter,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.secondary,
      content: Text(message, style: const TextStyle(color: Colors.white)),
      child: child,
    );
  }
}
