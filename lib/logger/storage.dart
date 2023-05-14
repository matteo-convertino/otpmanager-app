import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LoggerStorage {
  static const String fileName = "log";
  static const String extension = "txt";


  static Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> localFile() async {
    final path = await _localPath();
    return await File('$path/$fileName.$extension').create();
  }
}