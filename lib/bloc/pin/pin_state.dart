import 'package:equatable/equatable.dart';

class PinState extends Equatable {
  final int attempts;
  final String message;
  final bool isError;

  const PinState({
    required this.attempts,
    required this.message,
    required this.isError,
  });

  const PinState.initial()
      : attempts = 3,
        message = "",
        isError = false;

  PinState copyWith({int? attempts, String? message, bool? isError}) {
    return PinState(
      attempts: attempts ?? this.attempts,
      message: message ?? this.message,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object> get props => [attempts, message, isError];
}
