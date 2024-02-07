import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/account.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class NextcloudSync extends HomeEvent {}

class IsAppUpdatedChanged extends HomeEvent {
  const IsAppUpdatedChanged({required this.value});

  final bool value;

  @override
  List<Object> get props => [value];
}

class Logout extends HomeEvent {}

class SortById extends HomeEvent {}

class SortByName extends HomeEvent {}

class SortByIssuer extends HomeEvent {}

class GetAccounts extends HomeEvent {}

class Reorder extends HomeEvent {
  const Reorder({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class DeleteAccount extends HomeEvent {
  const DeleteAccount({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}

class IncrementCounter extends HomeEvent {
  const IncrementCounter({required this.account});

  final Account account;

  @override
  List<Object> get props => [account];
}

class SearchBarValueChanged extends HomeEvent {
  const SearchBarValueChanged({required this.value});

  final String value;

  @override
  List<Object> get props => [value];
}
