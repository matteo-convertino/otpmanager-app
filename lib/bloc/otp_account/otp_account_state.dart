import 'package:equatable/equatable.dart';

import '../../utils/optional.dart';

class OtpAccountState extends Equatable {
  final String? otpCode;
  final String? otpMessage;
  final bool disableIncrement;

  const OtpAccountState({
    required this.otpCode,
    required this.otpMessage,
    required this.disableIncrement,
  });

  const OtpAccountState.initial()
    : this(otpCode: null, otpMessage: null, disableIncrement: false);

  OtpAccountState copyWith({
    Optional<String>? otpCode,
    Optional<String>? otpMessage,
    bool? disableIncrement,
  }) {
    return OtpAccountState(
      otpCode: otpCode == null ? this.otpCode : otpCode.value,
      otpMessage: otpMessage == null ? this.otpMessage : otpMessage.value,
      disableIncrement: disableIncrement ?? this.disableIncrement,
    );
  }

  @override
  List<Object?> get props => [otpCode, otpMessage, disableIncrement];
}
