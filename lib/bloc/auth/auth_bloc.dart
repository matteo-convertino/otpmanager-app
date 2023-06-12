import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/auth/auth_event.dart';
import 'package:otp_manager/bloc/auth/auth_state.dart';

import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/routing/constants.dart';

import '../../models/user.dart';
import '../../routing/navigation_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final Account account;

  final NavigationService _navigationService = NavigationService();

  AuthBloc({
    required this.localRepositoryImpl,
    required this.account,
  }) : super(
    AuthState.initial(localRepositoryImpl.getUser()!),
  ) {
    on<Authenticated>(_onAuthenticated);
    on<PinSubmit>(_onPinSubmit);
  }

  void _error(Emitter<AuthState> emit) {
    emit(state.copyWith(attempts: state.attempts - 1));

    emit(state.copyWith(isError: false));
    emit(state.copyWith(isError: true));

    if (state.attempts == 0) {
      emit(state.copyWith(message: "You used too many attempts try again"));
      _navigationService.resetToScreen(homeRoute);
    }
  }

  void _onAuthenticated(Authenticated event, Emitter<AuthState> emit) {
    _navigationService.replaceScreen(
      manualRoute,
      arguments: {
        "account": account,
        "auth": true,
      },
    );
  }

  void _onPinSubmit(PinSubmit event, Emitter<AuthState> emit) {
    if (event.pin == state.pin) {
      add(Authenticated());
    } else {
      _error(emit);
    }
  }
}
