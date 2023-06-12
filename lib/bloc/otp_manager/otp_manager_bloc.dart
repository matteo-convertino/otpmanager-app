import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_event.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';

class OtpManagerBloc extends Bloc<OtpManagerEvent, OtpManagerState> {
  final LocalRepositoryImpl localRepositoryImpl;

  OtpManagerBloc({
    required this.localRepositoryImpl,
  }) : super(
          OtpManagerState.initial(
            localRepositoryImpl.getUser()?.darkTheme ?? false,
            localRepositoryImpl.getUser()?.copyWithTap ?? false,
            localRepositoryImpl.isLogged() ? homeRoute : loginRoute,
          ),
        ) {
    on<CopyWithTapToggled>(_onCopyWithTapToggled);
    on<DarkThemeToggled>(_onDarkThemeToggled);
  }

  void _onCopyWithTapToggled(
      CopyWithTapToggled event, Emitter<OtpManagerState> emit) {
    final user = localRepositoryImpl.getUser();
    user?.copyWithTap = !user.copyWithTap;
    localRepositoryImpl.updateUser(user!);
    emit(state.copyWith(copyWithTap: user.copyWithTap));
  }

  void _onDarkThemeToggled(
      DarkThemeToggled event, Emitter<OtpManagerState> emit) {
    final user = localRepositoryImpl.getUser();
    user?.darkTheme = !user.darkTheme;
    localRepositoryImpl.updateUser(user!);
    emit(state.copyWith(darkTheme: user.darkTheme));
  }
}
