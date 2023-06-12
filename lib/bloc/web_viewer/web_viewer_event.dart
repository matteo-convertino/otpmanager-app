import 'package:equatable/equatable.dart';

class WebViewerEvent extends Equatable {
  const WebViewerEvent();

  @override
  List<Object?> get props => [];
}

class InitNextcloudLogin extends WebViewerEvent {}

class UpdateLoadingScreen extends WebViewerEvent {
  const UpdateLoadingScreen({required this.percentage, required this.isLogin});

  final double percentage;
  final bool? isLogin;

  @override
  List<Object?> get props => [percentage, isLogin];
}
