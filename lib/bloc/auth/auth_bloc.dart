import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/dto/request/password_check_request_dto.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../../models/user.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final NextcloudService nextcloudService;

  late final User _user = userRepository.get()!;

  final _localAuth = LocalAuthentication();

  AuthBloc({required this.userRepository, required this.nextcloudService})
    : super(const AuthState.initial()) {
    on<Authenticated>(_onAuthenticated);
    on<PasswordSubmit>(_onPasswordSubmit);
    on<PasswordChanged>(_onPasswordChanged);
    on<ResetAttempts>(_onResetAttempts);
    on<ShowDeviceAuth>(_onShowDeviceAuth);
    on<InitAuth>(_onInitAuth);

    add(InitAuth());
  }

  Future<void> _onInitAuth(InitAuth event, Emitter<AuthState> emit) async {
    final hasBiometrics = await _hasBiometrics();
    final isDeviceSupported = await _localAuth.isDeviceSupported();

    emit(
      state.copyWith(
        canShowFingerAuth: hasBiometrics,
        canShowDeviceAuth: isDeviceSupported,
      ),
    );

    if (hasBiometrics) add(ShowDeviceAuth());
  }

  void _updatePasswordExpirationDate() {
    final now = DateTime.now();

    _user.passwordExpirationDate = switch (_user.passwordAskTime) {
      PasswordAskTime.never => null,
      PasswordAskTime.everyOpening => now,
      PasswordAskTime.oneMinutes => now.add(const Duration(minutes: 1)),
      PasswordAskTime.threeMinutes => now.add(const Duration(minutes: 3)),
      PasswordAskTime.fiveMinutes => now.add(const Duration(minutes: 5)),
    };

    userRepository.update(_user);
  }

  void _onResetAttempts(ResetAttempts event, Emitter<AuthState> emit) {
    emit(state.copyWith(attempts: 3));
  }

  Future<bool> _hasBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      final bool canAuthWithBiometrics = await _localAuth.canCheckBiometrics;

      return canAuthWithBiometrics &&
          (availableBiometrics.contains(BiometricType.fingerprint) ||
              availableBiometrics.contains(BiometricType.strong));
    } on PlatformException {
      getIt<SnackbarService>().showMessage(
        "Your device doesn't support biometric authentication or you don't have any registered fingerprints",
      );
      return false;
    }
  }

  void _onShowDeviceAuth(ShowDeviceAuth event, Emitter<AuthState> emit) async {
    if (state.canShowDeviceAuth) {
      try {
        final res = await _localAuth.authenticate(
          localizedReason: 'Scan fingerprint to authenticate',
        );

        if (res) add(Authenticated());
      } on LocalAuthException catch (e) {
        getIt<Logger>().e(e);
      }
    }
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.password, message: ''));
  }

  void _error(Emitter<AuthState> emit, String msg) {
    emit(state.copyWith(message: msg, attempts: state.attempts - 1));

    if (state.attempts == 0) {
      emit(state.copyWith(attempts: 3));
    }
  }

  void _onAuthenticated(Authenticated event, Emitter<AuthState> emit) {
    _updatePasswordExpirationDate();
    emit(state.copyWith(isCorrectPassword: true));
  }

  void _onPasswordSubmit(PasswordSubmit event, Emitter<AuthState> emit) async {
    if (_user.isGuest) {
      add(Authenticated());
      return;
    }

    if (_user.password == null || _user.iv == null) {
      await nextcloudService.checkPassword(
        PasswordCheckRequestDto(password: state.password),
        onComplete: (res) {
          _user.password = sha256
              .convert(utf8.encode(state.password))
              .toString();
          _user.iv = res.iv;

          userRepository.update(_user);
          add(Authenticated());
        },
        onFailed: (err) => _error(
          emit,
          'An error encountered while checking password. Retry after a while!',
        ),
        onError: () => _error(
          emit,
          'An error encountered while checking password. Retry after a while!',
        ),
      );
    } else if (_user.password ==
        sha256.convert(utf8.encode(state.password)).toString()) {
      add(Authenticated());
    } else {
      _error(emit, 'Incorrect Password');
    }
  }
}
