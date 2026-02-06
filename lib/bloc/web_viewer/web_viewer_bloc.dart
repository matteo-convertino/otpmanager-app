import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:nextcloud/core.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_event.dart';
import 'package:otp_manager/bloc/web_viewer/web_viewer_state.dart';
import 'package:otp_manager/models/user.dart';
import 'package:otp_manager/repository/api/otp_manager_api_client.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/api/get_otp_manager_dio.dart';
import 'package:otp_manager/utils/api/nextcloud_http_client.dart';

import '../../di/injection.dart';
import '../../routing/constants.dart';
import '../../routing/navigation_service.dart';

@injectable
class WebViewerBloc extends Bloc<WebViewerEvent, WebViewerState> {
  final UserRepository userRepository;
  final OtpManagerApiClient otpManagerApiClient;

  final NavigationService _navigationService = NavigationService();

  final String nextcloudUrl;

  NextcloudClient? _client;
  DynamiteResponse<LoginFlowV2, void>? _init;

  WebViewerBloc({
    @factoryParam required this.nextcloudUrl,
    required this.userRepository,
    required this.otpManagerApiClient,
  }) : super(const WebViewerState.initial()) {
    on<InitNextcloudLogin>(_onInitNextcloudLogin);
    on<UpdateLoadingScreen>(_onUpdateLoadingScreen);
    on<OnLoadStop>(_onLoadStop);
  }

  Future<void> _nextcloudLoginFlowV2(Emitter<WebViewerState> emit) async {
    _client = NextcloudClient(
      Uri.parse(nextcloudUrl),
      httpClient: NextcloudHttpClient(),
    );

    _init = await _client?.core.clientFlowLoginV2.init();

    emit(state.copyWith(initUrl: _init?.body.login));
    emit(state.copyWith(initUrl: ''));
  }

  void _onUpdateLoadingScreen(
    UpdateLoadingScreen event,
    Emitter<WebViewerState> emit,
  ) {
    emit(state.copyWith(isLogin: event.isLogin));
  }

  void _onLoadStop(OnLoadStop event, Emitter<WebViewerState> emit) async {
    add(
      const UpdateLoadingScreen(
        //percentage: 1,
        isLogin: false,
      ),
    );

    if (event.url.endsWith('grant') || event.url.endsWith('apptoken')) {
      final body = ClientFlowLoginV2PollRequestApplicationJson((b) {
        b.token = _init!.body.poll.token;
      });

      _client!.core.clientFlowLoginV2.poll($body: body).then((result) {
        userRepository.update(
          User(
            url: nextcloudUrl,
            appPassword: result.body.appPassword,
            isGuest: false,
          ),
        );
        otpManagerApiClient.dio = getOtpManagerDio(
          baseUrl: nextcloudUrl,
          token: result.body.appPassword,
        );
        _navigationService.resetToScreen(authRoute);
      });
    }
  }

  void _onInitNextcloudLogin(
    InitNextcloudLogin event,
    Emitter<WebViewerState> emit,
  ) async {
    await _nextcloudLoginFlowV2(
      emit,
    ).timeout(const Duration(seconds: 10)).catchError((error, stackTrace) {
      getIt<Logger>().e(error);

      if (error is TimeoutException) {
        getIt<SnackbarService>().showMessage(
          'The server is taking too time to respond!',
        );
        _navigationService.goBack();
      } else {
        getIt<SnackbarService>().showMessage(
          'The url is not of a valid nextcloud server!',
        );
        _navigationService.goBack();
      }
    });

    emit(state.copyWith(isLoading: false));
  }
}
