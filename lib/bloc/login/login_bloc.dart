import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/login/login_event.dart';
import 'package:otp_manager/bloc/login/login_state.dart';

import '../../main.dart' show logger;
import '../../models/user.dart';
import '../../repository/local_repository.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LocalRepositoryImpl localRepositoryImpl;

  final NavigationService _navigationService = NavigationService();

  LoginBloc({required this.localRepositoryImpl})
      : super(const LoginState.initial()) {
    on<UrlSubmit>(_onUrlSubmit);
    on<UrlChanged>(_onUrlChanged);
  }

  void _onUrlSubmit(UrlSubmit event, Emitter<LoginState> emit) {
    var url = Uri.parse(state.url.trim());

    if (url.toString() == "http://localhost") {
      localRepositoryImpl.updateUser(
        User(
          url: url.toString(),
          appPassword: "test",
          isGuest: true,
        ),
      );
      _navigationService.resetToScreen(homeRoute);
    } else {
      try {
        _navigationService.navigateTo(webViewerRoute,
            arguments: url.toString());
      } catch (e) {
        logger.e(e);

        emit(
          state.copyWith(
            url: url.toString(),
            error: "The URL entered is not valid!",
          ),
        );
      }
    }
  }

  void _onUrlChanged(UrlChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(url: event.url, error: ""));
  }
}
