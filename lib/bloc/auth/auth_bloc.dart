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
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../../models/user.dart';
import '../../routing/navigation_service.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;
  final NextcloudService nextcloudService;
  final NavigationService navigationService;

  late final User _user = userRepository.get()!;

  final _localAuth = LocalAuthentication();

  AuthBloc({
    required this.userRepository,
    required this.nextcloudService,
    required this.navigationService,
  }) : super(const AuthState.initial()) {
    on<Authenticated>(_onAuthenticated);
    on<PasswordSubmit>(_onPasswordSubmit);
    on<PasswordChanged>(_onPasswordChanged);
    on<ResetAttempts>(_onResetAttempts);
    on<ShowFingerAuth>(_onShowFingerAuth);

    if (_user.password != null) {
      add(ShowFingerAuth());
    }
  }

  void _updatePasswordExpirationDate() {
    if (_user.passwordAskTime == PasswordAskTime.never) {
      _user.passwordExpirationDate = null;
    } else if (_user.passwordAskTime == PasswordAskTime.everyOpening) {
      _user.passwordExpirationDate = DateTime.now();
    } else if (_user.passwordAskTime == PasswordAskTime.oneMinutes) {
      _user.passwordExpirationDate = DateTime.now().add(
        const Duration(minutes: 1),
      );
    } else if (_user.passwordAskTime == PasswordAskTime.threeMinutes) {
      _user.passwordExpirationDate = DateTime.now().add(
        const Duration(minutes: 3),
      );
    } else if (_user.passwordAskTime == PasswordAskTime.fiveMinutes) {
      _user.passwordExpirationDate = DateTime.now().add(
        const Duration(minutes: 5),
      );
    }

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

  void _onShowFingerAuth(ShowFingerAuth event, Emitter<AuthState> emit) async {
    final hasBiometrics = await _hasBiometrics();

    emit(state.copyWith(canShowFingerAuth: hasBiometrics));

    if (hasBiometrics) {
      try {
        final res = await _localAuth.authenticate(
          localizedReason: 'Scan Fingerprint to Authenticate',
          biometricOnly: true,
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
    navigationService.replaceScreen(homeRoute);
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
