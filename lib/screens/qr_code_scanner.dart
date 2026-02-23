import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_bloc.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_state.dart';

import '../widgets/otp_manager_qr_scanner_overlay_shape.dart';

class QrCodeScanner extends HookWidget {
  QrCodeScanner({super.key});

  final MobileScannerController _cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () =>
                context.read<QrCodeScannerBloc>().add(ShowImagePicker()),
          ),
        ],
      ),
      body: BlocConsumer<QrCodeScannerBloc, QrCodeScannerState>(
        listenWhen: (previous, current) => previous.image != current.image,
        listener: (context, state) async {
          if (state.image == null) return;

          final barcode = await _cameraController.analyzeImage(
            state.image!.path,
          );

          if (barcode != null && context.mounted) {
            context.read<QrCodeScannerBloc>().add(
              BarcodeCaptured(barcode: barcode),
            );
          }
        },
        builder: (context, state) {
          return MobileScanner(
            overlayBuilder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: ShapeDecoration(
                      shape: OtpManagerQrScannerOverlayShape(
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
            controller: _cameraController,
            onDetect: (BarcodeCapture barcodeCapture) => context
                .read<QrCodeScannerBloc>()
                .add(BarcodeCaptured(barcode: barcodeCapture)),
          );
        },
      ),
    );
  }
}
