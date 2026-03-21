import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_event.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';
import 'package:otp_manager/bloc/settings/settings_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/password_ask_time.dart';
import 'package:otp_manager/utils/enum/theme_mode.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_bug_dialog.dart';
import 'package:otp_manager/widgets/dialogs/otp_manager_recover_password_dialog.dart';
import 'package:otp_manager/widgets/otp_manager_animate_change_icon.dart';
import 'package:otp_manager/widgets/otp_manager_switch.dart';
import 'package:otp_manager/widgets/tooltip/otp_manager_tooltip.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Settings extends HookWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<SettingsBloc>().add(InitPackageInfo());
      return null;
    }, []);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [
              if (state.canRecoverPassword)
                IconButton(
                  onPressed: () => showOtpManagerRecoverPasswordDialog(context),
                  icon: const PhosphorIcon(PhosphorIconsRegular.key),
                ),
              IconButton(
                onPressed: () => showOtpManagerBugDialog(context),
                icon: const PhosphorIcon(PhosphorIconsRegular.bugBeetle),
              ),
            ],
          ),
          body: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Text(
                  'Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                title: const Text('Nextcloud server'),
                trailing: SizedBox(
                  width: 200,
                  child: Text(
                    state.url,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: state.url));
                  getIt<SnackbarService>().showMessage('URL copied');
                },
              ),
              ListTile(
                title: const Text('Version number'),
                trailing: Text(
                  '${state.packageInfo.version}.${state.packageInfo.buildNumber}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: Text(
                  'Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Theme mode'),
                trailing: Container(
                  padding: const .all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    shape: .circle,
                  ),
                  child: OtpManagerAnimateChangeIcon(
                    animateDuration: const Duration(milliseconds: 200),
                    initialIndex: context.select(
                      (OtpManagerBloc bloc) => bloc.state.themeMode.index,
                    ),
                    icons: [
                      PhosphorIcon(
                        PhosphorIconsRegular.sunDim,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 20,
                      ),
                      PhosphorIcon(
                        PhosphorIconsRegular.moon,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 20,
                      ),
                      PhosphorIcon(
                        PhosphorIconsRegular.deviceMobileCamera,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 20,
                      ),
                    ],
                    onTap: (i) => context.read<OtpManagerBloc>().add(
                      ThemeModeChanged(
                        themeMode: switch (i) {
                          0 => ThemeMode.light,
                          1 => ThemeMode.dark,
                          _ => ThemeMode.system,
                        },
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Row(
                  spacing: 8,
                  children: [
                    Text('Pure black'),
                    OtpManagerTooltip(
                      message: 'This applies when the app is used in dark mode',
                      child: PhosphorIcon(PhosphorIconsRegular.info),
                    ),
                  ],
                ),
                trailing: OtpManagerSwitch(
                  iconSelected: const PhosphorIcon(PhosphorIconsRegular.circle),
                  iconAny: const PhosphorIcon(
                    PhosphorIconsRegular.circleDashed,
                  ),
                  onChanged: (value) =>
                      context.read<OtpManagerBloc>().add(BlackThemeToggled()),
                  value: context.select(
                    (OtpManagerBloc bloc) => bloc.state.blackTheme,
                  ),
                ),
                onTap: () =>
                    context.read<OtpManagerBloc>().add(BlackThemeToggled()),
              ),
              ListTile(
                title: const Text('Copy code with tap'),
                trailing: OtpManagerSwitch(
                  iconSelected: const PhosphorIcon(
                    PhosphorIconsRegular.handTap,
                  ),
                  iconAny: const PhosphorIcon(PhosphorIconsRegular.handTap),
                  onChanged: (value) =>
                      context.read<OtpManagerBloc>().add(CopyWithTapToggled()),
                  value: context.select(
                    (OtpManagerBloc bloc) => bloc.state.copyWithTap,
                  ),
                ),
                onTap: () =>
                    context.read<OtpManagerBloc>().add(CopyWithTapToggled()),
              ),
              ListTile(
                title: const Text('Open search bar on startup'),
                trailing: OtpManagerSwitch(
                  iconSelected: const PhosphorIcon(
                    PhosphorIconsRegular.magnifyingGlass,
                  ),
                  iconAny: const PhosphorIcon(
                    PhosphorIconsRegular.magnifyingGlass,
                  ),
                  onChanged: (value) => context.read<OtpManagerBloc>().add(
                    OpenSearchBarOnStartupToggled(),
                  ),
                  value: context.select(
                    (OtpManagerBloc bloc) => bloc.state.openSearchBarOnStartup,
                  ),
                ),
                onTap: () => context.read<OtpManagerBloc>().add(
                  OpenSearchBarOnStartupToggled(),
                ),
              ),
              ListTile(
                title: const Row(
                  spacing: 8,
                  children: [
                    Text('Click to reveal code'),
                    OtpManagerTooltip(
                      message:
                          'This feature may cause a drop in performance '
                          'due to the animations. '
                          'If you notice this, '
                          'please keep this feature disabled.',
                      child: PhosphorIcon(PhosphorIconsRegular.info),
                    ),
                  ],
                ),
                trailing: OtpManagerSwitch(
                  iconSelected: const PhosphorIcon(PhosphorIconsRegular.eye),
                  iconAny: const PhosphorIcon(PhosphorIconsRegular.eyeSlash),
                  onChanged: (value) => context.read<OtpManagerBloc>().add(
                    ClickToRevealCodesToggled(),
                  ),
                  value: context.select(
                    (OtpManagerBloc bloc) => bloc.state.clickToRevealCodes,
                  ),
                ),
                onTap: () => context.read<OtpManagerBloc>().add(
                  ClickToRevealCodesToggled(),
                ),
              ),
              ListTile(
                title: const Text('Password ask time'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton2<PasswordAskTime>(
                    items: PasswordAskTime.values
                        .map(
                          (item) => DropdownMenuItem<PasswordAskTime>(
                            value: item,
                            child: Text(
                              item.label,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    value: PasswordAskTime.values[state.selectedAskTimeIndex],
                    onChanged: (PasswordAskTime? value) {
                      if (value == null) return;

                      context.read<SettingsBloc>().add(
                        AskTimeChanged(index: value.index),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
