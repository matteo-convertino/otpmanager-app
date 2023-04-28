import 'package:flutter/material.dart';

import "../routing/constants.dart";
import '../routing/navigation_service.dart';

class Import extends StatelessWidget {
  const Import({Key? key}) : super(key: key);

  GestureDetector listItem(String title, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          child: ListTile(
            title: Text(title),
            trailing: const Icon(
              Icons.keyboard_arrow_right_outlined,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import OTP"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            listItem(
              "Google Authenticator",
              () => NavigationService().navigateTo(qrCodeScannerRoute),
            ),
          ],
        ),
      ),
    );
  }
}
