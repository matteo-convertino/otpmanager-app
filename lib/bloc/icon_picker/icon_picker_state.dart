import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';

class IconPickerState extends Equatable {
  final Map<String, Icon> icons;
  final Map<String, Icon> iconsBestMatch;
  final String searchBarValue;
  final String issuer;

  const IconPickerState({
    required this.icons,
    required this.searchBarValue,
    required this.iconsBestMatch,
    required this.issuer,
  });

  IconPickerState.initial(this.issuer)
    : icons = OtpIconsHelper.simpleIcons,
      iconsBestMatch = {},
      searchBarValue = '';

  IconPickerState copyWith({
    Map<String, Icon>? icons,
    Map<String, Icon>? iconsBestMatch,
    String? searchBarValue,
  }) {
    return IconPickerState(
      icons: icons ?? this.icons,
      iconsBestMatch: iconsBestMatch ?? this.iconsBestMatch,
      searchBarValue: searchBarValue ?? this.searchBarValue,
      issuer: issuer,
    );
  }

  @override
  List<Object> get props => [icons, iconsBestMatch, searchBarValue];
}
