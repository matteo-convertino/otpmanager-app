import 'package:equatable/equatable.dart';

class AccountDetailsEvent extends Equatable {
  const AccountDetailsEvent();

  @override
  List<Object> get props => [];
}

class DeleteAccount extends AccountDetailsEvent {}
