import 'package:equatable/equatable.dart';

class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class InitPackageInfo extends SettingsEvent {}

class SaveLog extends SettingsEvent {}

class PasswordWhenOpeningToggled extends SettingsEvent {}

class OpenLink extends SettingsEvent {
  const OpenLink({required this.url});

  final String url;

  @override
  List<Object> get props => [url];
}

class CopyToClipboard extends SettingsEvent {
  const CopyToClipboard({required this.text});

  final String text;

  @override
  List<Object> get props => [text];
}

class AskTimeChanged extends SettingsEvent {
  const AskTimeChanged({required this.index});

  final int index;

  @override
  List<Object> get props => [index];
}
