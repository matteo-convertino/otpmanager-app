import 'package:equatable/equatable.dart';

class OtpManagerEvent extends Equatable {
  const OtpManagerEvent();

  @override
  List<Object> get props => [];
}

class CopyWithTapToggled extends OtpManagerEvent {}

class DarkThemeToggled extends OtpManagerEvent {}
