import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/home/home_bloc.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_event.dart';
import 'package:otp_manager/bloc/qr_code_scanner/qr_code_scanner_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/optional.dart';

import '../../models/account.dart';
import '../../utils/helper/otp_uri_decoder_helper.dart';

@injectable
class QrCodeScannerBloc extends Bloc<QrCodeScannerEvent, QrCodeScannerState> {
  final AccountRepository accountRepository;
  final AccountService accountService;
  final NavigationService navigationService;
  final HomeBloc homeBloc;

  final _imagePicker = ImagePicker();

  QrCodeScannerBloc({
    required this.accountRepository,
    required this.accountService,
    required this.navigationService,
    required this.homeBloc,
  }) : super(const QrCodeScannerState.initial()) {
    on<ErrorChanged>(_onErrorChanged);
    on<BarcodeCaptured>(_onBarcodeCaptured);
    on<ShowImagePicker>(_onShowImagePicker);
  }

  void _onShowImagePicker(
    ShowImagePicker event,
    Emitter<QrCodeScannerState> emit,
  ) async {
    final result = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (result != null) emit(state.copyWith(image: Optional(result)));
  }

  void _onErrorChanged(ErrorChanged event, Emitter<QrCodeScannerState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onBarcodeCaptured(
    BarcodeCaptured event,
    Emitter<QrCodeScannerState> emit,
  ) async {
    final raw = event.barcode.barcodes.first.rawValue;

    if (raw == null || !OtpUriDecoderHelper.isValid(raw)) {
      emit(state.copyWith(error: 'The QR code is not correct'));
      return;
    }

    List<Account> accounts = OtpUriDecoderHelper.decodeOtpUri(raw);

    var atLeastOneAdded = false;

    for (var account in accounts) {
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
              "${accounts.length > 1 ? "These accounts are already registered" : "This account is already registered"}.\nMake sure you are in sync and try again.",
        ),
      );
    } else {
      getIt<SnackbarService>().showMessage(
        accounts.length > 1
            ? 'New accounts have been added'
            : 'New account has been added',
      );

      homeBloc.add(NextcloudSync());
      navigationService.resetToScreen(homeRoute);
    }
  }
}
