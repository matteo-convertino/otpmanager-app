import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/login/login_event.dart';
import 'package:otp_manager/bloc/login/login_state.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';

import '../../models/user.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final NavigationService navigationService;

  LoginBloc({required this.userRepository, required this.navigationService})
    : super(const LoginState.initial()) {
    on<UrlSubmit>(_onUrlSubmit);
    on<UrlChanged>(_onUrlChanged);
  }

  void _onUrlSubmit(UrlSubmit event, Emitter<LoginState> emit) {
    String url = state.url.trim();

    url = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

    if (url.toString() == 'http://localhost') {
      userRepository.add(User(url: url, appPassword: 'test', isGuest: true));
      navigationService.resetToScreen(homeRoute);
    } else {
      navigationService.navigateTo(webViewerRoute, arguments: url);
    }
  }

  void _onUrlChanged(UrlChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(url: event.url));
  }
}
