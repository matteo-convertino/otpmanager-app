import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

class HomeFab extends StatelessWidget {
  const HomeFab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: Theme.of(context).primaryColor,
      animatedIcon: AnimatedIcons.menu_close,
      foregroundColor: Colors.white,
      overlayColor: Colors.grey,
      overlayOpacity: 0.2,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.keyboard),
          label: "Type configuration manually",
          onTap: () =>
              NavigationService().navigateTo(manualRoute, arguments: {}),
        ),
        SpeedDialChild(
          child: const Icon(Icons.qr_code_scanner),
          label: "Scan QR code",
          onTap: () => NavigationService().navigateTo(qrCodeScannerRoute),
        ),
        SpeedDialChild(
          child: const Icon(Icons.library_add_outlined),
          label: "Import OTP",
          onTap: () => NavigationService().navigateTo(importRoute),
        ),
        SpeedDialChild(
          child: const Icon(Icons.settings),
          label: "Settings",
          onTap: () => NavigationService().navigateTo(settingsRoute),
        ),
        SpeedDialChild(
          child: const Icon(Icons.logout),
          label: "Logout",
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Logout"),
              content: const Text(
                  "Are you sure that you want to logout from your Nextcloud account?"),
              actions: [
                TextButton(
                  child: const Text("No"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text("Yes"),
                  onPressed: () => context.read<HomeBloc>().add(Logout()),
                ),
              ],
            ),
          ),
        ),
      ],
      spaceBetweenChildren: 10,
      spacing: 10,
    );
  }
}
