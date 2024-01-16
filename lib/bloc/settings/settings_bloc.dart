import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';
import 'package:otp_manager/bloc/settings/settings_state.dart';
import 'package:otp_manager/models/user.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/logger/save_log.dart';
import 'package:otp_manager/utils/launch_url.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LocalRepositoryImpl localRepositoryImpl;

  SettingsBloc({required this.localRepositoryImpl})
      : super(SettingsState.initial(localRepositoryImpl.getUser()!)) {
    on<SaveLog>(_onSaveLog);
    on<InitPackageInfo>(_onInitPackageInfo);
    on<OpenLink>(_onOpenLink);
    on<CopyToClipboard>(_onCopyToClipboard);
    on<AskTimeChanged>(_onAskTimeChanged);
  }

  void _onSaveLog(SaveLog event, Emitter<SettingsState> emit) => saveLog();

  void _onInitPackageInfo(
      InitPackageInfo event, Emitter<SettingsState> emit) async {
    final info = await PackageInfo.fromPlatform();
    emit(state.copyWith(packageInfo: info));
  }

  void _onOpenLink(OpenLink event, Emitter<SettingsState> emit) =>
      customLaunchUrl(event.url);

  void _onCopyToClipboard(CopyToClipboard event, Emitter<SettingsState> emit) {
    Clipboard.setData(ClipboardData(text: event.text));
    emit(state.copyWith(copiedToClipboard: false));
    emit(state.copyWith(copiedToClipboard: true));
  }

  void _onAskTimeChanged(AskTimeChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(selectedAskTimeIndex: event.index));

    User user = localRepositoryImpl.getUser()!;

    user.dbPasswordAskTime = event.index;

    _updatePasswordExpirationDate(user);

    localRepositoryImpl.updateUser(user);
  }

  void _updatePasswordExpirationDate(User user) {
    if (user.passwordAskTime == PasswordAskTime.never) {
      user.passwordExpirationDate = null;
    } else if (user.passwordAskTime == PasswordAskTime.everyOpening) {
      user.passwordExpirationDate = DateTime.now();
    } else if (user.passwordAskTime == PasswordAskTime.oneMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 1));
    } else if (user.passwordAskTime == PasswordAskTime.threeMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 3));
    } else if (user.passwordAskTime == PasswordAskTime.fiveMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 5));
    }
  }
}
