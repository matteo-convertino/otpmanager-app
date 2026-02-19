import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp/otp.dart';
import 'package:otp_manager/dto/request/account_update_counter_request_dto.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/optional.dart';

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

  void _getOtpCodeOrMessage(Emitter<OtpAccountState> emit, dynamic account) {
    if (account is SharedAccount && !account.unlocked) {
      return emit(
        state.copyWith(
          otpCode: Optional(null),
          otpMessage: Optional('Click here to unlock your shared account'),
        ),
      );
    }

    if (account.type == OtpType.totp.value) {
      return emit(
        state.copyWith(
          otpCode: Optional(
            OTP.generateTOTPCodeString(
              account.secret,
              DateTime.now().millisecondsSinceEpoch,
              algorithm: account.algorithm,
              interval: account.period as int,
              length: account.digits as int,
              isGoogle: true,
            ),
          ),
          otpMessage: Optional(null),
        ),
      );
    }

    if (account.type == OtpType.hotp.value) {
      if (account.counter! >= 0) {
        return emit(
          state.copyWith(
            otpCode: Optional(
              OTP.generateHOTPCodeString(
                account.secret,
                account.counter!,
                algorithm: account.algorithm,
                length: account.digits as int,
                isGoogle: true,
              ),
            ),
            otpMessage: Optional(null),
          ),
        );
      }

      return emit(
        state.copyWith(
          otpCode: Optional(null),
          otpMessage: Optional('Click here to generate HOTP code'),
        ),
      );
    }

    return emit(
      state.copyWith(otpCode: Optional(null), otpMessage: Optional(null)),
    );
  }

  void _onIncrementCounter(
    IncrementCounter event,
    Emitter<OtpAccountState> emit,
  ) async {
    emit(state.copyWith(disableIncrement: true));

    await nextcloudService.updateCounter(
      AccountUpdateCounterRequestDto(secret: event.account.encryptedSecret),
      isShared: event.account is SharedAccount,
      onComplete: (res) {
        event.account.counter = res.counter;

        if (event.account is SharedAccount) {
          sharedAccountRepository.add(event.account);
        } else {
          accountRepository.add(event.account);
        }

        _getOtpCodeOrMessage(emit, event.account);
      },
    );

    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(disableIncrement: false));
  }

  void _onGenerateOtpCode(
    GenerateOtpCode event,
    Emitter<OtpAccountState> emit,
  ) {
    _getOtpCodeOrMessage(emit, event.account);
  }
}
