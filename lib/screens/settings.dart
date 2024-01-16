import 'package:dropdown_button2/dropdown_button2.dart';
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
import 'package:otp_manager/utils/show_snackbar.dart';

class Settings extends HookWidget {
  Settings({Key? key}) : super(key: key);

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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal),
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
                      showSnackBar(context: context, msg: "URL copied");
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
                    title: const Text("Password ask time"),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        dropdownWidth: 150.0,
                        items: askTimeOptions
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: askTimeOptions[state.selectedAskTimeIndex],
                        onChanged: (String? value) {
                          context.read<SettingsBloc>().add(AskTimeChanged(
                              index: askTimeOptions.indexOf(value!)));
                        },
                      ),
                    ),
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
