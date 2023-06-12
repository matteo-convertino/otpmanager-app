import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/user.dart';

class AuthState extends Equatable {
  final int attempts;
  final String pin;
  final String message;
  final bool isError;

  const AuthState({
    required this.attempts,
    required this.pin,
    required this.message,
    required this.isError,
  });

  AuthState.initial(User user)
      : attempts = 3,
        pin = user.pin!,
        message = "",
        isError = false;

  AuthState copyWith({int? attempts, String? message, bool? isError}) {
    return AuthState(
      attempts: attempts ?? this.attempts,
      pin: pin,
      message: message ?? this.message,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object> get props => [attempts, message, isError];
}
