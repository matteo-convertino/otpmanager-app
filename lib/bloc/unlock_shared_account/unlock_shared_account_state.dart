import 'package:equatable/equatable.dart';

class UnlockSharedAccountState extends Equatable {
  final int attempts;
  final String password;
  final String message;
  final String errorMsg;

  const UnlockSharedAccountState({
    required this.attempts,
    required this.password,
    required this.message,
    required this.errorMsg,
  });

  const UnlockSharedAccountState.initial()
    : attempts = 3,
      password = '',
      message = '',
      errorMsg = '';
  UnlockSharedAccountState copyWith({
    int? attempts,
    String? password,
    String? message,
    String? errorMsg,
    bool? canShowFingerAuth,
  }) {
    return UnlockSharedAccountState(
      attempts: attempts ?? this.attempts,
      password: password ?? this.password,
      message: message ?? this.message,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object> get props => [attempts, password, message, errorMsg];
}
