import 'package:flutter/material.dart';

Tooltip tooltip(String text, Icon icon) {
  return Tooltip(
    message: text,
    triggerMode: TooltipTriggerMode.tap,
    showDuration: const Duration(seconds: 2),
    verticalOffset: 20,
    decoration: const BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    textStyle: const TextStyle(color: Colors.white),
    child: icon,
  );
}
