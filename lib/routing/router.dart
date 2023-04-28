import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otp_manager/screens/pin.dart';

import '../models/account.dart';
import '../screens/account_details.dart';
import '../screens/auth.dart';
import '../screens/home.dart';
import '../screens/import.dart';
import '../screens/login.dart';
import '../screens/manual.dart';
import '../screens/qr_code_scanner.dart';
import '../screens/settings.dart';
import '../screens/web_viewer.dart';
import 'constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return CupertinoPageRoute(builder: (_) => const Home());
      case importRoute:
        return CupertinoPageRoute(builder: (_) => const Import());
      case settingsRoute:
        return CupertinoPageRoute(
            builder: (_) =>
                Settings(updateHome: settings.arguments as Function));
      case qrCodeScannerRoute:
        return CupertinoPageRoute(builder: (_) => const QrCodeScanner());
      case accountDetailsRoute:
        return CupertinoPageRoute(
            builder: (_) =>
                AccountDetails(account: settings.arguments as Account));
      case loginRoute:
        return CupertinoPageRoute(
            builder: (_) => Login(error: (settings.arguments ?? "") as String));
      case webViewerRoute:
        return CupertinoPageRoute(
            builder: (_) => WebViewer(url: settings.arguments as String));
      case manualRoute:
        Map arguments = settings.arguments as Map;
        Account? account = arguments["account"];
        bool? isAuthenticated = arguments["auth"];

        if (account == null) {
          return CupertinoPageRoute(builder: (_) => const Manual());
        } else {
          if (isAuthenticated == true) {
            return CupertinoPageRoute(builder: (_) => Manual(account: account));
          } else {
            return CupertinoPageRoute(builder: (_) => Auth(account: account));
          }
        }
      case pinRoute:
        Map arguments = settings.arguments as Map;
        bool toEdit = arguments["toEdit"] ?? false;
        String newPassword = arguments["newPassword"] ?? "";
        String title = newPassword != ""
            ? "Confirm new pin"
            : toEdit
                ? "Old pin"
                : "New pin";

        return CupertinoPageRoute(
          builder: (_) =>
              Pin(title: title, toEdit: toEdit, newPassword: newPassword),
        );
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
