import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String url;

  const LoginState({required this.url});

  const LoginState.initial() : url = '';

  LoginState copyWith({String? url}) {
    return LoginState(url: url ?? this.url);
  }

  @override
  List<Object> get props => [url];
}
