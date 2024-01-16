import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:otp_manager/utils/simple_icons.dart';

class IconPickerState extends Equatable {
  final Map<String, Icon> icons;
  final String searchBarValue;

  const IconPickerState({
    required this.icons,
    required this.searchBarValue,
  });

  const IconPickerState.initial()
      : icons = simpleIcons,
        searchBarValue = "";

  IconPickerState copyWith({Map<String, Icon>? icons, String? searchBarValue}) {
    return IconPickerState(
      icons: icons ?? this.icons,
      searchBarValue: searchBarValue ?? this.searchBarValue,
    );
  }

  @override
  List<Object> get props => [icons, searchBarValue];
}