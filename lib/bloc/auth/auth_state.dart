import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/user.dart';

class AuthState extends Equatable {
  final int attempts;
  final String password;
  final String message;
  final bool isError;
  final bool canShowFingerAuth;

  const AuthState({
    required this.attempts,
    required this.password,
    required this.message,
    required this.isError,
    required this.canShowFingerAuth,
  });

  AuthState.initial(User user)
      : attempts = 3,
        password = user.password ?? "",
        message = "",
        isError = false,
        canShowFingerAuth = false;

  AuthState copyWith({
    int? attempts,
    String? password,
    String? message,
    bool? isError,
    bool? canShowFingerAuth,
  }) {
    return AuthState(
      attempts: attempts ?? this.attempts,
      password: password ?? this.password,
      message: message ?? this.message,
      isError: isError ?? this.isError,
      canShowFingerAuth: canShowFingerAuth ?? this.canShowFingerAuth,
    );
  }

  @override
  List<Object> get props =>
      [attempts, password, message, isError, canShowFingerAuth];
}
