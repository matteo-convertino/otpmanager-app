import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_state.dart';

import '../utils/helper/otp_uri_decoder_helper.dart';
import '../widgets/otp_manager_qr_scanner_overlay_shape.dart';

class QrCodeScanner extends HookWidget {
  QrCodeScanner({super.key});

  final MobileScannerController _cameraController = MobileScannerController();
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () async {
              final XFile? result = await picker.pickImage(
                source: ImageSource.gallery,
              );

              if (result != null &&
                  await _cameraController.analyzeImage(result.path) == null) {
                if (context.mounted) {
                  context.read<QrCodeScannerBloc>().add(
                    const ErrorChanged(
                      error: "The image doesn't contain a QR code",
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<QrCodeScannerBloc, QrCodeScannerState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _cameraController,
                onDetect: (BarcodeCapture barcodeCapture) {
                  if (OtpUriDecoderHelper.isValid(
                    barcodeCapture.raw!.toString(),
                  )) {
                    context.read<QrCodeScannerBloc>().add(
                      DecodeAndStoreAccounts(
                        accounts: barcodeCapture.raw!.toString(),
                      ),
                    );
                  } else {
                    context.read<QrCodeScannerBloc>().add(
                      const ErrorChanged(error: 'The QR code is not correct'),
                    );
                  }
                },
              ),
              Container(
                decoration: ShapeDecoration(
                  shape: OtpManagerQrScannerOverlayShape(
                    borderWidth: 5,
                    borderLength: 20,
                    borderRadius: 10,
                    borderColor: Colors.blueGrey,
                    cutOutSize: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                child: Text(
                  state.error,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
