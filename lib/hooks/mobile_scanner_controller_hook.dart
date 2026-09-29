import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScannerController useMobileScannerController({bool invertImage = false}) {
  final controller = useMemoized(
    () => MobileScannerController(invertImage: invertImage),
    [invertImage],
  );

  useEffect(() {
    return () => unawaited(controller.dispose());
  }, [controller]);

  return controller;
}
