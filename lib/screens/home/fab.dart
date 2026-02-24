import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_logout.dart';
import 'package:otp_manager/widgets/otp_manager_animated_gradient.dart';

import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';
import '../../widgets/dialogs/otp_manager_support_dialog.dart';

class HomeFab extends HookWidget {
  const HomeFab({super.key});

  @override
  Widget build(BuildContext context) {
    final bird = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final waving = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );
    final isFabOpen = useState(false);

    final darkTheme = context.select<OtpManagerBloc, bool>(
      (b) => b.state.darkTheme,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          bottom: 45,
          child: Lottie.asset(
            'assets/lottie/bird.json',
            controller: bird,
            width: 56,
            onLoaded: (composition) {
              bird.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  Future.delayed(
                    const Duration(milliseconds: 2000),
                    bird.reverse,
                  );
                } else if (status == AnimationStatus.dismissed &&
                    !isFabOpen.value) {
                  Future.delayed(
                    const Duration(milliseconds: 2000),
                    bird.forward,
                  );
                }
              });

              bird.forward();
            },
          ),
        ),
        SpeedDial(
          onOpen: () {
            isFabOpen.value = true;
            bird.stop();
            bird.animateTo(0);
          },
          onClose: () {
            isFabOpen.value = false;
            bird.forward();
            waving.stop();
            waving.value = 0;
          },
          backgroundColor: Theme.of(context).primaryColor,
          animatedIcon: AnimatedIcons.menu_close,
          foregroundColor: Colors.white,
          overlayOpacity: 0.5,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.keyboard),
              label: 'Type configuration manually',
              onTap: () => getIt<NavigationService>().navigateTo(
                manualRoute,
                arguments: {},
              ),
            ),
            SpeedDialChild(
              child: const Icon(Icons.qr_code_scanner),
              label: 'Scan QR code',
              onTap: () =>
                  getIt<NavigationService>().navigateTo(qrCodeScannerRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.library_add_outlined),
              label: 'Import OTP',
              onTap: () => getIt<NavigationService>().navigateTo(importRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.settings),
              label: 'Settings',
              onTap: () => getIt<NavigationService>().navigateTo(settingsRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.logout),
              label: 'Logout',
              onTap: () => showOtpManagerLogoutDialog(context),
            ),
            SpeedDialChild(
              child: OtpManagerAnimatedGradient(
                secondaryColors: const [
                  Color(0x00ffcd3f),
                  Color(0x00ffbd2b),
                  Color(0x00ffb223),
                ],
                primaryColors: const [
                  Colors.amber,
                  Colors.amberAccent,
                  Colors.yellow,
                ],
                borderRadius: BorderRadius.circular(16),
                width: double.infinity,
                height: double.infinity,
                child: Lottie.asset(
                  'assets/lottie/bird_waving.json',
                  controller: waving,
                  onLoaded: (composition) {
                    waving.addStatusListener((status) {
                      if (status == AnimationStatus.completed) {
                        Future.delayed(
                          const Duration(milliseconds: 1000),
                          () => waving.forward(from: 0),
                        );
                      }
                    });

                    waving.forward();
                  },
                ),
              ),
              backgroundColor: darkTheme
                  ? Colors.amber.shade100
                  : Colors.amber.shade50,
              onTap: () => showOtpManagerSupportDialog(context),
            ),
          ],
          spaceBetweenChildren: 10,
          spacing: 10,
        ),
      ],
    );
  }
}
