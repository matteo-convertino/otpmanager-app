import 'package:equatable/equatable.dart';
import 'package:otp_manager/utils/enum/theme_mode.dart';

class OtpManagerEvent extends Equatable {
  const OtpManagerEvent();

  @override
  List<Object> get props => [];
}

class Logout extends OtpManagerEvent {}

class CopyWithTapToggled extends OtpManagerEvent {}

class OpenSearchBarOnStartupToggled extends OtpManagerEvent {}

class ClickToRevealCodesToggled extends OtpManagerEvent {}

class BlackThemeToggled extends OtpManagerEvent {}

class ThemeModeChanged extends OtpManagerEvent {
  const ThemeModeChanged({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object> get props => [themeMode];
}
