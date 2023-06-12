import 'package:equatable/equatable.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewerState extends Equatable {
  final double percentage;
  final bool isLogin;
  final bool isLoading;
  final String error;
  final WebViewController webViewController;

  const WebViewerState({
    required this.isLogin,
    required this.percentage,
    required this.isLoading,
    required this.error,
    required this.webViewController,
  });

  WebViewerState.initial()
      : percentage = 0.0,
        isLogin = false,
        isLoading = true,
        error = "",
        webViewController = WebViewController();

  WebViewerState copyWith(
      {double? percentage,
      bool? isLogin,
      bool? isLoading,
      String? error,
      WebViewController? webViewController}) {
    return WebViewerState(
      percentage: percentage ?? this.percentage,
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      webViewController: webViewController ?? this.webViewController,
    );
  }

  @override
  List<Object> get props =>
      [percentage, isLogin, isLoading, error, webViewController];
}
