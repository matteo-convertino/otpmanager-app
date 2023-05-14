import 'dart:io';

import 'package:logger/logger.dart';
import 'package:otp_manager/logger/storage.dart';

class FileOutput extends LogOutput {

  @override
  void output(OutputEvent event) async {
    for (var line in event.lines) {
      File file = await LoggerStorage.localFile();
      await file.writeAsString(
        "${line.toString()}\n",
        mode: FileMode.writeOnlyAppend,
      );
    }
  }
}
