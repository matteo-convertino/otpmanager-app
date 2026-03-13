import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
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
import 'package:otp_manager/widgets/dialogs/otp_manager_bug_dialog.dart';
import 'package:otp_manager/widgets/otp_manager_switch.dart';
import 'package:otp_manager/widgets/tooltip/otp_manager_tooltip.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Settings extends HookWidget {
  Settings({super.key});

  final List<String> askTimeOptions = [
    'Every Opening',
    'After 1 minute',
    'After 3 minutes',
    'After 5 minutes',
    'Never',
  ];

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<SettingsBloc>().add(InitPackageInfo());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () => showOtpManagerBugDialog(context),
            icon: const PhosphorIcon(PhosphorIconsRegular.bugBeetle),
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
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
                title: const Text('Dark theme'),
                trailing: OtpManagerSwitch(
                  iconSelected: const PhosphorIcon(PhosphorIconsRegular.moon),
                  iconAny: const PhosphorIcon(PhosphorIconsRegular.sunDim),
                  onChanged: (value) =>
                      context.read<OtpManagerBloc>().add(DarkThemeToggled()),
                  value: context.select(
                    (OtpManagerBloc bloc) => bloc.state.darkTheme,
                  ),
                ),
                onTap: () =>
                    context.read<OtpManagerBloc>().add(DarkThemeToggled()),
              ),
              ListTile(
                title: const Text('Open Search Bar on Startup'),
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
                  child: DropdownButton2<String>(
                    items: askTimeOptions
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    value: askTimeOptions[state.selectedAskTimeIndex],
                    onChanged: (String? value) {
                      context.read<SettingsBloc>().add(
                        AskTimeChanged(index: askTimeOptions.indexOf(value!)),
                      );
                    },
                  ),
                ),
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
            ],
          );
        },
      ),
    );
  }
}
