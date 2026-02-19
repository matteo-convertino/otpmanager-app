import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../../models/account.dart';
import '../../utils/helper/otp_uri_decoder_helper.dart';

@injectable
class QrCodeScannerBloc extends Bloc<QrCodeScannerEvent, QrCodeScannerState> {
  final AccountRepository accountRepository;
  final AccountService accountService;
  final NavigationService navigationService;

  QrCodeScannerBloc({
    required this.accountRepository,
    required this.accountService,
    required this.navigationService,
  }) : super(const QrCodeScannerState.initial()) {
    on<ErrorChanged>(_onErrorChanged);
    on<DecodeAndStoreAccounts>(_onDecodeAndStoreAccounts);
  }

  void _onErrorChanged(ErrorChanged event, Emitter<QrCodeScannerState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onDecodeAndStoreAccounts(
    DecodeAndStoreAccounts event,
    Emitter<QrCodeScannerState> emit,
  ) async {
    List<Account> newAccounts = OtpUriDecoderHelper.decodeOtpUri(
      event.accounts,
    );

    var atLeastOneAdded = false;

    for (var account in newAccounts) {
      if (!accountRepository.alreadyExists(account.secret)) {
        atLeastOneAdded = true;
        account.position = accountService.getLastPosition() + 1;
        accountRepository.add(account);
      }
    }

    if (!atLeastOneAdded) {
      emit(
        state.copyWith(
          error:
              "${newAccounts.length > 1 ? "These accounts are already registered" : "This account is already registered"}.\nMake sure you are in sync and try again.",
        ),
      );
    } else {
      getIt<SnackbarService>().showMessage(
        newAccounts.length > 1
            ? 'New accounts have been added'
            : 'New account has been added',
      );
      navigationService.resetToScreen(homeRoute);
    }
  }
}
