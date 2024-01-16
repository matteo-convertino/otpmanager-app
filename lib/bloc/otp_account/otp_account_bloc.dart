import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp/otp.dart';
import 'package:otp_manager/models/account.dart';

import '../../repository/local_repository.dart';
import '../home/home_bloc.dart';
import '../home/home_event.dart' hide IncrementCounter;
import 'otp_account_event.dart';
import 'otp_account_state.dart';

class OtpAccountBloc extends Bloc<OtpAccountEvent, OtpAccountState> {
  final HomeBloc homeBloc;
  final LocalRepositoryImpl localRepositoryImpl;

  OtpAccountBloc({
    required this.homeBloc,
    required this.localRepositoryImpl,
  }) : super(const OtpAccountState.initial()) {
    on<IncrementCounter>(_onIncrementCounter);
    on<GenerateOtpCode>(_onGenerateOtpCode);
  }

  String _getOtp(Account account) {
    if (account.type == "totp") {
      return OTP.generateTOTPCodeString(
        account.secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: account.algorithm,
        interval: account.period as int,
        length: account.digits as int,
        isGoogle: true,
      );
    } else if (account.counter! > 0) {
      return OTP.generateHOTPCodeString(
        account.secret,
        account.counter!,
        algorithm: account.algorithm,
        length: account.digits as int,
        isGoogle: true,
      );
    }
    return "null";
  }

  void _onIncrementCounter(
      IncrementCounter event, Emitter<OtpAccountState> emit) async {
    event.account.counter = event.account.counter! + 1;
    event.account.toUpdate = true;
    localRepositoryImpl.updateAccount(event.account);

    emit(state.copyWith(otpCode: _getOtp(event.account)));

    homeBloc.add(NextcloudSync());
  }

  void _onGenerateOtpCode(
      GenerateOtpCode event, Emitter<OtpAccountState> emit) async {
    emit(state.copyWith(otpCode: _getOtp(event.account)));
  }
}
