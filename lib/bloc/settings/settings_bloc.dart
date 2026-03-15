import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';
import 'package:otp_manager/bloc/settings/settings_state.dart';
import 'package:otp_manager/logger/save_log.dart';
import 'package:otp_manager/models/user.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/utils/launch_url.dart';
import 'package:package_info_plus/package_info_plus.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserRepository userRepository;

  SettingsBloc({required this.userRepository})
    : super(SettingsState.initial(userRepository.get()!)) {
    on<SaveLog>(_onSaveLog);
    on<InitPackageInfo>(_onInitPackageInfo);
    on<OpenLink>(_onOpenLink);
    on<CopyToClipboard>(_onCopyToClipboard);
    on<AskTimeChanged>(_onAskTimeChanged);
  }

  void _onSaveLog(SaveLog event, Emitter<SettingsState> emit) => saveLog();

  void _onInitPackageInfo(
    InitPackageInfo event,
    Emitter<SettingsState> emit,
  ) async {
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

    User user = userRepository.get()!;
    user.dbPasswordAskTime = event.index;
    user.updatePasswordExpirationDate();

    userRepository.update(user);
  }
}
