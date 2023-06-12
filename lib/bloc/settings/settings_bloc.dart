import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/settings/settings_event.dart';
import 'package:otp_manager/bloc/settings/settings_state.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/logger/save_log.dart';
import 'package:otp_manager/utils/launch_url.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final LocalRepositoryImpl localRepositoryImpl;

  SettingsBloc({
    required this.localRepositoryImpl,
  }) : super(
          SettingsState.initial(localRepositoryImpl.getUser()!),
        ) {
    on<SaveLog>(_onSaveLog);
    on<InitPackageInfo>(_onInitPackageInfo);
    on<PinClicked>(_onPinClicked);
    on<OpenLink>(_onOpenLink);
    on<CopyToClipboard>(_onCopyToClipboard);
  }

  void _onSaveLog(SaveLog event, Emitter<SettingsState> emit) => saveLog();

  void _onInitPackageInfo(
      InitPackageInfo event, Emitter<SettingsState> emit) async {
    final info = await PackageInfo.fromPlatform();
    emit(state.copyWith(packageInfo: info));
  }

  void _onPinClicked(PinClicked event, Emitter<SettingsState> emit) {}

  void _onOpenLink(OpenLink event, Emitter<SettingsState> emit) =>
      customLaunchUrl(event.url);

  void _onCopyToClipboard(CopyToClipboard event, Emitter<SettingsState> emit) {
    Clipboard.setData(ClipboardData(text: event.text));
    emit(state.copyWith(copiedToClipboard: false));
    emit(state.copyWith(copiedToClipboard: true));
  }
}
