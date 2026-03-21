import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final int attempts;
  final String password;
  final String message;
  final bool canShowDeviceAuth;
  final bool canShowFingerAuth;
  final bool isUserPasswordEmpty;
  final bool isCorrectPassword;
  final bool isRecoveringPassword;

  const AuthState({
    required this.attempts,
    required this.password,
    required this.message,
    required this.canShowDeviceAuth,
    required this.canShowFingerAuth,
    required this.isUserPasswordEmpty,
    required this.isCorrectPassword,
    required this.isRecoveringPassword,
  });

  const AuthState.initial({this.isRecoveringPassword = false})
    : attempts = 3,
      password = '',
      message = '',
      canShowDeviceAuth = false,
      canShowFingerAuth = false,
      isUserPasswordEmpty = true,
      isCorrectPassword = false;

  AuthState copyWith({
    int? attempts,
    String? password,
    String? message,
    bool? canShowDeviceAuth,
    bool? canShowFingerAuth,
    bool? isUserPasswordEmpty,
    bool? isCorrectPassword,
  }) {
    return AuthState(
      attempts: attempts ?? this.attempts,
      password: password ?? this.password,
      message: message ?? this.message,
      canShowDeviceAuth: canShowDeviceAuth ?? this.canShowDeviceAuth,
      canShowFingerAuth: canShowFingerAuth ?? this.canShowFingerAuth,
      isUserPasswordEmpty: isUserPasswordEmpty ?? this.isUserPasswordEmpty,
      isCorrectPassword: isCorrectPassword ?? this.isCorrectPassword,
      isRecoveringPassword: isRecoveringPassword,
    );
  }

  @override
  List<Object> get props => [
    attempts,
    password,
    message,
    canShowDeviceAuth,
    canShowFingerAuth,
    isUserPasswordEmpty,
    isCorrectPassword,
  ];
}
