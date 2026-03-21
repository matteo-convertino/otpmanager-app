import 'package:equatable/equatable.dart';

class RecoverPasswordEvent extends Equatable {
  const RecoverPasswordEvent();

  @override
  List<Object> get props => [];
}

class NewPasswordChanged extends RecoverPasswordEvent {
  const NewPasswordChanged({required this.newPassword});

  final String newPassword;

  @override
  List<Object> get props => [newPassword];
}

class OldPasswordChanged extends RecoverPasswordEvent {
  const OldPasswordChanged({required this.oldPassword});

  final String oldPassword;

  @override
  List<Object> get props => [oldPassword];
}

class RecoverPasswordSubmit extends RecoverPasswordEvent {}
