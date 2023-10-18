import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/utils/base32.dart';

import '../../domain/nextcloud_service.dart';
import '../../models/user.dart';
import '../../routing/navigation_service.dart';
import '../../utils/encryption.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final NextcloudService nextcloudService;
  final Account? account;
  final List accountsToAdd;
  final List accountsToEdit;
  late User user = localRepositoryImpl.getUser()!;

  final NavigationService _navigationService = NavigationService();

  AuthBloc({
    required this.localRepositoryImpl,
    required this.nextcloudService,
    this.account,
    required this.accountsToAdd,
    required this.accountsToEdit,
  }) : super(
          AuthState.initial(localRepositoryImpl.getUser()!),
        ) {
    on<Authenticated>(_onAuthenticated);
    on<PasswordSubmit>(_onPasswordSubmit);
    on<PasswordChanged>(_onPasswordChanged);
    on<ResetAttempts>(_onResetAttempts);
    on<ShowFingerAuth>(_onShowFingerAuth);

    if (user.password != null &&
        user.iv != null &&
        (user.passwordExpirationDate == null ||
            DateTime.now().isBefore(user.passwordExpirationDate!))) {
      add(Authenticated());
    } else if (state.password != "") {
      add(ShowFingerAuth());
    }
  }

  void _updatePasswordExpirationDate() {
    if (user.passwordAskTime == PasswordAskTime.never) {
      user.passwordExpirationDate = null;
    } else if (user.passwordAskTime == PasswordAskTime.everySync) {
      user.passwordExpirationDate = DateTime.now();
    } else if (user.passwordAskTime == PasswordAskTime.oneMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 1));
    } else if (user.passwordAskTime == PasswordAskTime.threeMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 3));
    } else if (user.passwordAskTime == PasswordAskTime.fiveMinutes) {
      user.passwordExpirationDate =
          DateTime.now().add(const Duration(minutes: 5));
    }

    localRepositoryImpl.updateUser(user);
  }

  void _onResetAttempts(ResetAttempts event, Emitter<AuthState> emit) {
    emit(state.copyWith(attempts: 3));
  }

  void _onShowFingerAuth(ShowFingerAuth event, Emitter<AuthState> emit) {
    emit(state.copyWith(canShowFingerAuth: true));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.password, message: ""));
  }

  void _error(Emitter<AuthState> emit, String msg) {
    emit(state.copyWith(message: msg, attempts: state.attempts - 1));

    if (state.attempts == 0) {
      emit(state.copyWith(attempts: 3));
    }

    emit(state.copyWith(isError: false));
    emit(state.copyWith(isError: true));
  }

  bool _decryptSecretAccounts(List accounts) {
    for (var account in accounts) {
      account["encryptedSecret"] = account["secret"];

      try {
        var decrypted =
            Encryption.decrypt(account["secret"], user.password!, user.iv!);

        if (!Base32.isValid(decrypted)) throw FormatException;

        account["secret"] = decrypted;
      } catch (_) {
        user.password = null;
        user.iv = null;
        localRepositoryImpl.updateUser(user);
        return false;
      }
    }

    return true;
  }

  void _syncAccountsToAddToEdit(Emitter<AuthState> emit) {
    if (_decryptSecretAccounts(accountsToAdd) &&
        _decryptSecretAccounts(accountsToEdit)) {
      localRepositoryImpl.addNewAccounts(accountsToAdd);
      localRepositoryImpl.updateEditedAccounts(accountsToEdit);

      _updatePasswordExpirationDate();
      _navigationService.resetToScreen(homeRoute);
    } else {
      _error(emit, "Password has changed. Insert the new one");
    }
  }

  void _onAuthenticated(Authenticated event, Emitter<AuthState> emit) {
    if (account == null) {
      _syncAccountsToAddToEdit(emit);
    } else {
      _updatePasswordExpirationDate();
      _navigationService.replaceScreen(
        manualRoute,
        arguments: {
          "account": account,
          "auth": true,
        },
      );
    }
  }

  void _onPasswordSubmit(PasswordSubmit event, Emitter<AuthState> emit) async {
    if (account == null) {
      String password;
      String iv;

      if (user.password == null || user.iv == null) {
        Map<String, String?> result =
            await nextcloudService.checkPassword(state.password);

        if (result["error"] == null && result["iv"] != null) {
          password = sha256.convert(utf8.encode(state.password)).toString();
          iv = result["iv"]!;

          user.password = password;
          user.iv = iv;

          localRepositoryImpl.updateUser(user);
        } else {
          _error(emit, result["error"]!);
          return;
        }
      } else {
        if (user.password ==
            sha256.convert(utf8.encode(state.password)).toString()) {
          password = user.password!;
          iv = user.iv!;
        } else {
          _error(emit, "Incorrect Password");
          return;
        }
      }

      _syncAccountsToAddToEdit(emit);
    } else {
      if (user.password ==
          sha256.convert(utf8.encode(state.password)).toString()) {
        add(Authenticated());
      } else {
        _error(emit, "Incorrect Password");
      }
    }
  }
}
