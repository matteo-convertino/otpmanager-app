import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_state.dart';
import 'package:otp_manager/repository/local_repository.dart';

import '../../models/account.dart';
import '../../utils/uri_decoder.dart';

class QrCodeScannerBloc extends Bloc<QrCodeScannerEvent, QrCodeScannerState> {
  final LocalRepositoryImpl localRepositoryImpl;

  QrCodeScannerBloc({required this.localRepositoryImpl})
      : super(
          const QrCodeScannerState.initial(),
        ) {
    on<ErrorChanged>(_onErrorChanged);
    on<DecodeAndStoreAccounts>(_onDecodeAndStoreAccounts);
  }

  void _onErrorChanged(ErrorChanged event, Emitter<QrCodeScannerState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onDecodeAndStoreAccounts(
      DecodeAndStoreAccounts event, Emitter<QrCodeScannerState> emit) async {
    List<Account> newAccounts = UriDecoder().decodeQrCode(
      event.accounts,
      isGoogle: UriDecoder.isGoogle(event.accounts),
    );

    var atLeastOneAdded = false;

    for (var account in newAccounts) {
      if (!localRepositoryImpl.accountAlreadyExists(account.secret)) {
        atLeastOneAdded = true;
        localRepositoryImpl.addAccount(account);
      }
    }

    if (!atLeastOneAdded) {
      emit(state.copyWith(
          error: newAccounts.length > 1
              ? "These accounts are already registered"
              : "This account is already registered"));
    } else {
      emit(state.copyWith(
          addWithSuccess: newAccounts.length > 1
              ? "New accounts have been added"
              : "New account has been added"));
    }
  }
}
