import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class UrlSubmit extends LoginEvent {}

class UrlChanged extends LoginEvent {
  const UrlChanged({required this.url});

  final String url;

  @override
  List<Object> get props => [url];
}
