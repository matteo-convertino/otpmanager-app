import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/screens/home/app_bar.dart';
import 'package:otp_manager/screens/home/body.dart';
import 'package:otp_manager/screens/home/fab.dart';
import 'package:upgrader/upgrader.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        showIgnore: false,
        showLater: false,
        durationUntilAlertAgain: const Duration(seconds: 1),
      ),
      child: const Scaffold(
        appBar: HomeAppBar(),
        body: HomeBody(),
        floatingActionButton: HomeFab(),
      ),
    );
  }
}
