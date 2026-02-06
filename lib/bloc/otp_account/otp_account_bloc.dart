import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp/otp.dart';
import 'package:otp_manager/dto/request/account_update_counter_request_dto.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/service/nextcloud_service.dart';

import '../home/home_bloc.dart';
import 'otp_account_event.dart';
import 'otp_account_state.dart';

@injectable
class OtpAccountBloc extends Bloc<OtpAccountEvent, OtpAccountState> {
  final HomeBloc homeBloc;
  final AccountRepository accountRepository;
  final NextcloudService nextcloudService;
  final SharedAccountRepository sharedAccountRepository;

  OtpAccountBloc({
    required this.homeBloc,
    required this.accountRepository,
    required this.nextcloudService,
    required this.sharedAccountRepository,
  }) : super(const OtpAccountState.initial()) {
    on<IncrementCounter>(_onIncrementCounter);
    on<GenerateOtpCode>(_onGenerateOtpCode);
  }

  String _getOtp(dynamic account) {
    if (account is SharedAccount && !account.unlocked) {
      return "Click here to unlock your shared account";
    }

    if (account.type == "totp") {
      return OTP.generateTOTPCodeString(
        account.secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: account.algorithm,
        interval: account.period as int,
        length: account.digits as int,
        isGoogle: true,
      );
    } else if (account.type == "hotp") {
      if (account.counter! >= 0) {
        return OTP.generateHOTPCodeString(
          account.secret,
          account.counter!,
          algorithm: account.algorithm,
          length: account.digits as int,
          isGoogle: true,
        );
      }
      return "Click here to generate HOTP code";
    }

    return "null";
  }

  void _onIncrementCounter(
    IncrementCounter event,
    Emitter<OtpAccountState> emit,
  ) async {
    emit(state.copyWith(disableIncrement: true));

    await nextcloudService.updateCounter(
      AccountUpdateCounterRequestDto(id: event.account.id),
      isShared: event.account is SharedAccount,
      onComplete: (res) {
        event.account.counter = res.counter;

        if (event.account is SharedAccount) {
          sharedAccountRepository.add(event.account); // update without sync
        } else {
          accountRepository.add(event.account); // update without sync
        }

        emit(state.copyWith(otpCode: _getOtp(event.account)));
      },
    );

    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(disableIncrement: false));
  }

  void _onGenerateOtpCode(
    GenerateOtpCode event,
    Emitter<OtpAccountState> emit,
  ) async {
    emit(state.copyWith(otpCode: _getOtp(event.account)));
  }
}
