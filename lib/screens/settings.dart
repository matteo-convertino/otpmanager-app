import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_event.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/bloc/settings/settings_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';
import 'package:otp_manager/bloc/settings/settings_state.dart';
import 'package:otp_manager/routing/navigation_service.dart';

import "../routing/constants.dart";
import '../utils/toast.dart';

class Settings extends HookWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<SettingsBloc>().add(InitPackageInfo());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Bug Report"),
                  content: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium,
                      text: "If you have found a bug and want to report "
                          "it to the developer, contact him via email on ",
                      children: [
                        TextSpan(
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          text: "matteo@convertino.cloud",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.read<SettingsBloc>().add(const OpenLink(
                                  url: 'mailto:matteo@convertino.cloud'));
                            },
                        ),
                        const TextSpan(text: " or open an issue on "),
                        TextSpan(
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          text: "github",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.read<SettingsBloc>().add(const OpenLink(
                                  url:
                                      'https://github.com/matteo-convertino/otpmanager-app/issues'));
                            },
                        ),
                        const TextSpan(
                            text: ", attaching the log"
                                " file that you can download from here."),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Download Log"),
                      onPressed: () =>
                          context.read<SettingsBloc>().add(SaveLog()),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.bug_report),
          )
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Center(
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  ListTile(
                    title: const Text("Nextcloud server"),
                    trailing: Text(
                      state.url,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: state.url));
                      showToast("URL copied");
                    },
                  ),
                  BlocBuilder<OtpManagerBloc, OtpManagerState>(
                    builder: (context, state) {
                      return ListTile(
                        title: const Text("Copy code with tap"),
                        trailing: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: state.copyWithTap,
                          onChanged: (value) => context
                              .read<OtpManagerBloc>()
                              .add(CopyWithTapToggled()),
                        ),
                        onTap: () => context
                            .read<OtpManagerBloc>()
                            .add(CopyWithTapToggled()),
                      );
                    },
                  ),
                  BlocBuilder<OtpManagerBloc, OtpManagerState>(
                    builder: (context, state) {
                      return ListTile(
                        title: const Text("Dark theme"),
                        trailing: Checkbox(
                          activeColor: Theme.of(context).primaryColor,
                          value: state.darkTheme,
                          onChanged: (value) => context
                              .read<OtpManagerBloc>()
                              .add(DarkThemeToggled()),
                        ),
                        onTap: () => context
                            .read<OtpManagerBloc>()
                            .add(DarkThemeToggled()),
                      );
                    },
                  ),
                  ListTile(
                    title: state.pin != null && state.pin != ""
                        ? const Text("Change pin")
                        : const Text("Set pin"),
                    trailing: const Text(
                      "⬤⬤⬤⬤⬤⬤",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      NavigationService().navigateTo(pinRoute, arguments: {
                        "toEdit": state.pin != null && state.pin != "",
                      });
                    },
                  ),
                  ListTile(
                    title: const Text("Version number"),
                    trailing: Text(
                      "${state.packageInfo.version}.${state.packageInfo.buildNumber}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ).toList(),
            ),
          );
        },
      ),
    );
  }
}
