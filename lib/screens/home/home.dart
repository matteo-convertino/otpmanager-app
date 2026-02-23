import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/home/home_bloc.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/screens/home/app_bar.dart';
import 'package:otp_manager/screens/home/body.dart';
import 'package:otp_manager/screens/home/fab.dart';
import 'package:upgrader/upgrader.dart';

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showIgnore: false,
      showLater: true,
      onLater: () {
        context.read<HomeBloc>().add(NextcloudSync());
        return true;
      },
      upgrader: Upgrader(
        debugLogging: false,
        durationUntilAlertAgain: const Duration(hours: 2),
        willDisplayUpgrade:
            ({
              required bool display,
              String? installedVersion,
              UpgraderVersionInfo? versionInfo,
            }) {
              if (!display) {
                context.read<HomeBloc>().add(
                  const IsAppUpdatedChanged(value: true),
                );
              }
            },
      ),
      child: const Scaffold(
        appBar: HomeAppBar(),
        body: HomeBody(),
        floatingActionButton: HomeFab(),
      ),
    );
  }
}
