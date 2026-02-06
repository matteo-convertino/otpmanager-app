import 'package:equatable/equatable.dart';

class WebViewerState extends Equatable {
  final bool isLogin;
  final bool isLoading;
  final String initUrl;

  const WebViewerState({
    required this.isLogin,
    required this.isLoading,
    required this.initUrl,
  });

  const WebViewerState.initial()
    : isLogin = false,
      isLoading = true,
      initUrl = "";

  WebViewerState copyWith({
    double? percentage,
    bool? isLogin,
    bool? isLoading,
    String? initUrl,
  }) {
    return WebViewerState(
      isLogin: isLogin ?? this.isLogin,
      isLoading: isLoading ?? this.isLoading,
      initUrl: initUrl ?? this.initUrl,
    );
  }

  @override
  List<Object> get props => [isLogin, isLoading, initUrl];
}
