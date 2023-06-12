import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class Authenticated extends AuthEvent {}

class PinSubmit extends AuthEvent {
  const PinSubmit({required this.pin});

  final String pin;

  @override
  List<Object> get props => [pin];
}
