import 'package:flutter/material.dart';
import 'package:otp_manager/utils/simple_icons.dart';

import "../routing/constants.dart";
import '../routing/navigation_service.dart';

class Import extends StatelessWidget {
  const Import({Key? key}) : super(key: key);

  Widget listItem(Icon? icon, String title, Function onTap) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => onTap(),
          child: ListTile(
            leading: icon,
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
              simpleIcons["google"],
              "Google Authenticator",
              () => NavigationService().navigateTo(qrCodeScannerRoute),
            ),
          ],
        ),
      ),
    );
  }
}
