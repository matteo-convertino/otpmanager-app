import 'package:file_saver/file_saver.dart';
import 'package:otp_manager/logger/storage.dart';

void saveLog() async {
  var file = await LoggerStorage.localFile();

  await FileSaver.instance.saveAs(
    name: LoggerStorage.fileName,
    file: file,
    ext: LoggerStorage.extension,
    mimeType: MimeType.text,
  );
}
