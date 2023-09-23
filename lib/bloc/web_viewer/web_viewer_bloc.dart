import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_event.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_state.dart';
import 'package:otp_manager/models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../main.dart' show logger;
import '../../repository/local_repository.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

class WebViewerBloc extends Bloc<WebViewerEvent, WebViewerState> {
  final LocalRepositoryImpl localRepositoryImpl;

  final NavigationService _navigationService = NavigationService();

  final String nextcloudUrl;

  WebViewerBloc({required this.nextcloudUrl, required this.localRepositoryImpl})
      : super(WebViewerState.initial()) {
    on<InitNextcloudLogin>(_onInitNextcloudLogin);
    on<UpdateLoadingScreen>(_onUpdateLoadingScreen);
  }

  Future<NextcloudCoreLoginFlowInit> _nextcloudLoginSetup() async {
    final client = NextcloudClient(
      nextcloudUrl,
      userAgentOverride: 'OTP Manager App',
    );

    final NextcloudCoreLoginFlowInit init = await client.core.initLoginFlow();

    state.webViewController
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            add(
              const UpdateLoadingScreen(
                percentage: 1,
                isLogin: false,
              ),
            );

            if (url.endsWith("grant") || url.endsWith("apptoken")) {
              client.core
                  .getLoginFlowResult(token: init.poll.token)
                  .then((result) {
                localRepositoryImpl.updateUser(
                  User(
                    url: nextcloudUrl,
                    appPassword: result.appPassword,
                    isGuest: false,
                  ),
                );
                _navigationService.resetToScreen(homeRoute);
              });
            }
          },
          onPageStarted: (String? url) {
            add(
              UpdateLoadingScreen(
                percentage: 0,
                isLogin: url?.contains("flow") == true,
              ),
            );
          },
          onProgress: (int progressValue) {
            add(
              UpdateLoadingScreen(
                percentage: progressValue / 100,
                isLogin: null,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(init.login));

    return init;
  }

  void _onUpdateLoadingScreen(
      UpdateLoadingScreen event, Emitter<WebViewerState> emit) {
    emit(state.copyWith(percentage: event.percentage, isLogin: event.isLogin));
  }

  void _onInitNextcloudLogin(
      InitNextcloudLogin event, Emitter<WebViewerState> emit) async {
    state.webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    await _nextcloudLoginSetup()
        .timeout(const Duration(seconds: 10))
        .catchError((error, stackTrace) {
      if (error is TimeoutException) {
        logger.e(error);
        emit(
            state.copyWith(error: "The server is taking too time to respond!"));
        _navigationService.goBack();
      } else {
        logger.e(error);
        emit(state.copyWith(
            error: "The url is not of a valid nextcloud server!"));
        _navigationService.goBack();
      }
    });

    emit(state.copyWith(isLoading: false));
  }
}
