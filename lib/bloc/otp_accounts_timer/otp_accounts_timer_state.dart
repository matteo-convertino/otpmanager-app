import 'package:equatable/equatable.dart';

class OtpAccountsTimerState extends Equatable {
  const OtpAccountsTimerState({
    required this.remaining30,
    required this.remaining45,
    required this.remaining60,
  });

  factory OtpAccountsTimerState.fromTimestamp(int secondsSinceEpoch) {
    return OtpAccountsTimerState(
      remaining30: _remainingSeconds(secondsSinceEpoch, 30),
      remaining45: _remainingSeconds(secondsSinceEpoch, 45),
      remaining60: _remainingSeconds(secondsSinceEpoch, 60),
    );
  }

  final int remaining30;
  final int remaining45;
  final int remaining60;

  static int _remainingSeconds(int secondsSinceEpoch, int period) =>
      period - (secondsSinceEpoch % period);

  @override
  List<Object> get props => [remaining30, remaining45, remaining60];
}
