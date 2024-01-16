import 'package:equatable/equatable.dart';

class OtpAccountState extends Equatable {
  final String? otpCode;

  const OtpAccountState({required this.otpCode});

  const OtpAccountState.initial() : this(otpCode: null);

  OtpAccountState copyWith({String? otpCode}) {
    return OtpAccountState(
        otpCode: otpCode == "null" ? null : otpCode ?? this.otpCode);
  }

  @override
  List<Object?> get props => [otpCode];
}
