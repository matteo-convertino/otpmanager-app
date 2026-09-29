import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScannerController useMobileScannerController() {
  final controller = useMemoized(MobileScannerController.new, []);

  useOnAppLifecycleStateChange((previousState, currentState) {
    if (!controller.value.hasCameraPermission) return;

    switch (currentState) {
      case AppLifecycleState.resumed:
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(controller.stop());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
    }
  });

  useEffect(() => controller.dispose, [controller]);

  return controller;
}
