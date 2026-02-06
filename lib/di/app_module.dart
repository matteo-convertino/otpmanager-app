import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart' hide FileOutput;
import 'package:otp_manager/logger/file_output.dart';
import 'package:otp_manager/logger/filter.dart';

@module
abstract class AppModule {
  @lazySingleton
  Logger get logger => Logger(
    filter: Filter(),
    printer: PrettyPrinter(
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      colors: false,
      methodCount: 4,
    ),
    output: MultiOutput([FileOutput(), ConsoleOutput()]),
  );

  @lazySingleton
  GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      GlobalKey<ScaffoldMessengerState>();
}
