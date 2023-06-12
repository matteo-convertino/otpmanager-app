import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/pin/pin_event.dart';
import 'package:otp_manager/bloc/pin/pin_state.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';

import '../../models/user.dart';
import '../../routing/navigation_service.dart';

class PinBloc extends Bloc<PinEvent, PinState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final String title;
  final bool toEdit;
  final String? newPassword;

  late final User user = localRepositoryImpl.getUser()!;

  final NavigationService _navigationService = NavigationService();

  PinBloc({
    required this.localRepositoryImpl,
    required this.title,
    required this.toEdit,
    this.newPassword,
  }) : super(
          const PinState.initial(),
        ) {
    on<PinSubmit>(_onPinSubmit);
  }

  void _error(Emitter<PinState> emit) {
    emit(state.copyWith(attempts: state.attempts - 1));

    emit(state.copyWith(isError: false));
    emit(state.copyWith(isError: true));

    if (state.attempts == 0) {
      emit(state.copyWith(message: "You used too many attempts try again"));
      _navigationService.resetToScreen(homeRoute);
    }
  }

  void _onPinSubmit(PinSubmit event, Emitter<PinState> emit) {
    if (newPassword != null && newPassword != "") {
      if (event.pin == newPassword) {
        //user.copyWith(pin: event.pin);
        user.pin = event.pin;
        localRepositoryImpl.updateUser(user);

        emit(state.copyWith(message: "Pin successfully updated"));
        _navigationService.resetToScreen(homeRoute);
      } else {
        _error(emit);
      }
    } else if (toEdit) {
      if (event.pin == user.pin) {
        _navigationService.replaceScreen(pinRoute, arguments: {
          "toEdit": false,
        });
      } else {
        _error(emit);
      }
    } else {
      if (RegExp(r'^\d+$').hasMatch(event.pin)) {
        _navigationService.replaceScreen(pinRoute, arguments: {
          "newPassword": event.pin,
        });
      } else {
        _error(emit);
        emit(state.copyWith(message: "You can insert only digits"));
      }
    }
  }
}
