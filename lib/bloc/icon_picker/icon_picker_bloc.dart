import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_event.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_state.dart';
import 'package:otp_manager/utils/simple_icons.dart';

import '../../repository/local_repository.dart';

class IconPickerBloc extends Bloc<IconPickerEvent, IconPickerState> {
  final LocalRepositoryImpl localRepositoryImpl;

  IconPickerBloc({required this.localRepositoryImpl})
      : super(const IconPickerState.initial()) {
    on<SearchBarValueChanged>(_onSearchBarValueChanged);
  }

  void _onSearchBarValueChanged(SearchBarValueChanged event, Emitter<IconPickerState> emit) {
    emit(state.copyWith(searchBarValue: event.value));

    if (event.value.isEmpty) {
      emit(state.copyWith(icons: simpleIcons));
    } else {
      emit(state.copyWith(icons: Map.from(simpleIcons)..removeWhere((k, v) => !k.contains(event.value))));
    }
  }
}