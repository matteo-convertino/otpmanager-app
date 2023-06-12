import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String url;
  final String error;

  const LoginState({
    required this.url,
    required this.error,
  });

  const LoginState.initial()
      : url = "",
        error = "";

  LoginState copyWith({String? url, String? error}) {
    return LoginState(
      url: url ?? this.url,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [url, error];
}
