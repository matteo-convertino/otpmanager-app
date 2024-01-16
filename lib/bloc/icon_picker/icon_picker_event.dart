import 'package:equatable/equatable.dart';

class IconPickerEvent extends Equatable {
  const IconPickerEvent();

  @override
  List<Object> get props => [];
}

class SearchBarValueChanged extends IconPickerEvent {
  const SearchBarValueChanged({required this.value});

  final String value;

  @override
  List<Object> get props => [value];
}
