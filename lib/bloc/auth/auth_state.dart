import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final int attempts;
  final String password;
  final String message;
  final bool canShowFingerAuth;
  final bool isUserPasswordEmpty;

  const AuthState({
    required this.attempts,
    required this.password,
    required this.message,
    required this.canShowFingerAuth,
    required this.isUserPasswordEmpty,
  });

  const AuthState.initial()
      : attempts = 3,
        password = "",
        message = "",
        canShowFingerAuth = false,
        isUserPasswordEmpty = true;

  AuthState copyWith({
    int? attempts,
    String? password,
    String? message,
    bool? canShowFingerAuth,
    bool? isUserPasswordEmpty,
  }) {
    return AuthState(
      attempts: attempts ?? this.attempts,
      password: password ?? this.password,
      message: message ?? this.message,
      canShowFingerAuth: canShowFingerAuth ?? this.canShowFingerAuth,
      isUserPasswordEmpty: isUserPasswordEmpty ?? this.isUserPasswordEmpty,
    );
  }

  @override
  List<Object> get props => [
        attempts,
        password,
        message,
        canShowFingerAuth,
        isUserPasswordEmpty,
      ];
}
