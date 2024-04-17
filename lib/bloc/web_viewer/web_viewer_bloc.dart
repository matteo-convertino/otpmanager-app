import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud/core.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_event.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_state.dart';
import 'package:otp_manager/models/user.dart';
import 'package:otp_manager/repository/interface/user_repository.dart';

import '../../main.dart' show logger;
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

class WebViewerBloc extends Bloc<WebViewerEvent, WebViewerState> {
  final UserRepository userRepository;

  final NavigationService _navigationService = NavigationService();

  final String nextcloudUrl;

  NextcloudClient? _client;
  DynamiteResponse<LoginFlowV2, void>? _init;

  WebViewerBloc({required this.nextcloudUrl, required this.userRepository})
      : super(const WebViewerState.initial()) {
    on<InitNextcloudLogin>(_onInitNextcloudLogin);
    on<UpdateLoadingScreen>(_onUpdateLoadingScreen);
    on<OnLoadStop>(_onLoadStop);
  }

  Future<void> _nextcloudLoginFlowV2(Emitter<WebViewerState> emit) async {
    _client = NextcloudClient(
      Uri.parse(nextcloudUrl),
      userAgentOverride: 'OTP Manager App',
    );

    _init = await _client?.core.clientFlowLoginV2.init();

    emit(state.copyWith(initUrl: _init?.body.login));
    emit(state.copyWith(initUrl: ""));
  }

  void _onUpdateLoadingScreen(
      UpdateLoadingScreen event, Emitter<WebViewerState> emit) {
    emit(state.copyWith(
        /*percentage: event.percentage,*/ isLogin: event.isLogin));
  }

  void _onLoadStop(OnLoadStop event, Emitter<WebViewerState> emit) async {
    add(
      const UpdateLoadingScreen(
        //percentage: 1,
        isLogin: false,
      ),
    );

    if (event.url.endsWith("grant") || event.url.endsWith("apptoken")) {
      _client!.core.clientFlowLoginV2
          .poll(token: _init!.body.poll.token)
          .then((result) {
        userRepository.update(
          User(
            url: nextcloudUrl,
            appPassword: result.body.appPassword,
            isGuest: false,
          ),
        );
        _navigationService.resetToScreen(authRoute);
      });
    }
  }

  void _onInitNextcloudLogin(
      InitNextcloudLogin event, Emitter<WebViewerState> emit) async {
    //state.webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    await _nextcloudLoginFlowV2(emit)
        .timeout(const Duration(seconds: 10))
        .catchError((error, stackTrace) {
      logger.e(error);

      if (error is TimeoutException) {
        emit(
            state.copyWith(error: "The server is taking too time to respond!"));
        _navigationService.goBack();
      } else {
        emit(state.copyWith(
            error: "The url is not of a valid nextcloud server!"));
        _navigationService.goBack();
      }
    });

    emit(state.copyWith(isLoading: false));
  }
}
