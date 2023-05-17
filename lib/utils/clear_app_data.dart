import 'dart:io';

import 'package:path_provider/path_provider.dart';

void clearAppData() async {
  var appDir = (await getApplicationDocumentsDirectory()).path;
  Directory(appDir).delete(recursive: true);
}