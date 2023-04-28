import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import "../main.dart" show objectBox;
import '../models/account.dart';
import '../object_box/objectbox.g.dart';
import '../routing/constants.dart';
import '../routing/navigation_service.dart';
import "../utils/qr_scanner_overlay_shape.dart";
import '../utils/toast.dart';
import '../utils/uri_decoder.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final MobileScannerController _cameraController = MobileScannerController();
  final picker = ImagePicker();

  String errorLabel = "";

  void _decodeAndStoreAccounts(String uri) async {
    var box = objectBox.store.box<Account>();
    List<Account> newAccounts =
        UriDecoder().decodeQrCode(uri, isGoogle: UriDecoder.isGoogle(uri));

    var atLeastOneAdded = false;

    for (var account in newAccounts) {
      if (box
          .query(Account_.secret.contains(account.secret))
          .build()
          .find()
          .isEmpty) {
        atLeastOneAdded = true;
        box.put(account);
      }
    }

    if (!atLeastOneAdded) {
      errorLabel = newAccounts.length > 1
          ? "These accounts are already registered"
          : "This account is already registered";
      return;
    }

    showToast(newAccounts.length > 1
        ? "New accounts have been added"
        : "New account has been added");
    NavigationService().resetToScreen(homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () async {
              final XFile? result =
                  await picker.pickImage(source: ImageSource.gallery);

              if (result != null) {
                if (!await _cameraController.analyzeImage(result.path)) {
                  setState(
                      () => errorLabel = "The image doesn't contain a QR code");
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
              controller: _cameraController,
              onDetect: (Barcode barcode, MobileScannerArguments? args) {
                if (UriDecoder.isValid(barcode.rawValue!)) {
                  _decodeAndStoreAccounts(barcode.rawValue!);
                } else {
                  errorLabel = "The QR code is not correct";
                }

                setState(() {});
              }),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
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
              errorLabel,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
