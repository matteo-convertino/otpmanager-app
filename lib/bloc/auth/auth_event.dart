import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class Authenticated extends AuthEvent {}

class PasswordChanged extends AuthEvent {
  const PasswordChanged({required this.password});

  final String password;

  @override
  List<Object> get props => [password];
}

class PasswordSubmit extends AuthEvent {}

class ResetAttempts extends AuthEvent {}

class ShowFingerAuth extends AuthEvent {}
