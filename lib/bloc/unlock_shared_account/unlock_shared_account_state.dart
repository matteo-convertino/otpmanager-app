import 'package:equatable/equatable.dart';

class UnlockSharedAccountState extends Equatable {
  final int attempts;
  final String password;
  final String message;
  final String errorMsg;
  final bool isCorrectPassword;

  const UnlockSharedAccountState({
    required this.attempts,
    required this.password,
    required this.message,
    required this.errorMsg,
    required this.isCorrectPassword,
  });

  const UnlockSharedAccountState.initial()
    : attempts = 3,
      password = '',
      message = '',
      errorMsg = '',
      isCorrectPassword = false;

  UnlockSharedAccountState copyWith({
    int? attempts,
    String? password,
    String? message,
    String? errorMsg,
    bool? isCorrectPassword,
  }) {
    return UnlockSharedAccountState(
      attempts: attempts ?? this.attempts,
      password: password ?? this.password,
      message: message ?? this.message,
      errorMsg: errorMsg ?? this.errorMsg,
      isCorrectPassword: isCorrectPassword ?? this.isCorrectPassword,
    );
  }

  @override
  List<Object> get props => [
    attempts,
    password,
    message,
    errorMsg,
    isCorrectPassword,
  ];
}
