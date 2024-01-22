import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../models/account.dart';

void showQrCodeModal(
  BuildContext context,
  Account account,
) =>
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Scan your OTP account"),
        content: SizedBox(
          width: 300,
          height: 300,
          child: Center(
            child: PrettyQrView.data(
              data: account.toUri(),
              decoration: PrettyQrDecoration(
                shape: PrettyQrSmoothSymbol(
                  color: Theme.of(context).primaryColor,
                ),
                image: const PrettyQrDecorationImage(
                  padding: EdgeInsets.all(20),
                  scale: 0.15,
                  image: AssetImage('./assets/images/app_icon.png'),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
