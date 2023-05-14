import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileOutput extends LogOutput {
  final String fileName = "log.txt";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  @override
  void output(OutputEvent event) async {
    for (var line in event.lines) {
      File file = await _localFile;
      await file.writeAsString(
        "${line.toString()}\n",
        mode: FileMode.writeOnlyAppend,
      );
    }
  }
}
