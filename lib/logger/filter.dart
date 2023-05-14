import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Filter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) return true;

    return event.level == Level.error;
  }
}
