import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_event.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_state.dart';
import 'package:otp_manager/utils/simple_icons.dart';

import '../../repository/local_repository.dart';

class IconPickerBloc extends Bloc<IconPickerEvent, IconPickerState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final String issuer;

  IconPickerBloc({required this.localRepositoryImpl, required this.issuer})
      : super(IconPickerState.initial(issuer)) {
    on<SearchBarValueChanged>(_onSearchBarValueChanged);
    on<InitIcons>(_onInitIcons);

    add(InitIcons());
  }

  void _onInitIcons(InitIcons event, Emitter<IconPickerState> emit) {
    if (issuer != "") {
      Map<String, Icon> iconsBestMatch = {};

      simpleIcons.forEach((key, value) {
        if (iconsBestMatch.length != 3 && key.contains(issuer)) {
          iconsBestMatch[key] = value;
        }
      });

      emit(state.copyWith(iconsBestMatch: iconsBestMatch));
    }
  }

  void _onSearchBarValueChanged(
      SearchBarValueChanged event, Emitter<IconPickerState> emit) {
    emit(state.copyWith(searchBarValue: event.value));

    if (event.value.isEmpty) {
      emit(state.copyWith(icons: simpleIcons));
    } else {
      emit(state.copyWith(
          icons: Map.from(simpleIcons)
            ..removeWhere((k, v) => !k.contains(event.value))));
    }
  }
}
