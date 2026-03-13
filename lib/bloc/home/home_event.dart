import 'package:equatable/equatable.dart';

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
  const DeleteAccount({required this.account});

  final dynamic account; // Account | SharedAccount

  @override
  List<Object> get props => [account];
}

class SearchBarValueChanged extends HomeEvent {
  const SearchBarValueChanged({required this.value});

  final String value;

  @override
  List<Object> get props => [value];
}
