import 'dart:io';

import 'package:image/image.dart' as image;
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScannerHelper {
  static Future<BarcodeCapture?> analyzeImage(
    MobileScannerController controller,
    String path,
  ) async {
    final capture = await controller.analyzeImage(path);
    if (capture?.barcodes.isNotEmpty ?? false) return capture;

    final source = image.decodeImage(await File(path).readAsBytes());
    if (source == null) return capture;

    // A QR code requires a quiet zone around all four sides
    final padding =
        (source.width > source.height ? source.width : source.height) ~/ 5;
    final padded = image.copyExpandCanvas(
      source,
      padding: padding,
      backgroundColor: image.ColorRgb8(255, 255, 255),
    );
    final temporaryFile = File(
      '${Directory.systemTemp.path}/otp_manager_qr_${DateTime.now().microsecondsSinceEpoch}.png',
    );

    try {
      await temporaryFile.writeAsBytes(image.encodePng(padded));
      return await controller.analyzeImage(temporaryFile.path);
    } finally {
      if (await temporaryFile.exists()) await temporaryFile.delete();
    }
  }
}
