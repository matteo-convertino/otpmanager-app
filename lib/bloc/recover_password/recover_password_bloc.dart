import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_event.dart';
import 'package:otp_manager/bloc/recover_password/recover_password_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/dto/request/password_update_request_dto.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

@injectable
class RecoverPasswordBloc
    extends Bloc<RecoverPasswordEvent, RecoverPasswordState> {
  final NextcloudService nextcloudService;
  final UserRepository userRepository;

  RecoverPasswordBloc({
    required this.nextcloudService,
    required this.userRepository,
  }) : super(const RecoverPasswordState.initial()) {
    on<NewPasswordChanged>(_onNewPasswordChanged);
    on<OldPasswordChanged>(_onOldPasswordChanged);
    on<RecoverPasswordSubmit>(_onRecoverPasswordSubmit);
  }

  void _error(Emitter<RecoverPasswordState> emit, String msg) {
    emit(state.copyWith(errorMsg: msg, attempts: state.attempts - 1));

    if (state.attempts == 0) {
      emit(state.copyWith(attempts: 3));
    }
  }

  void _onNewPasswordChanged(
    NewPasswordChanged event,
    Emitter<RecoverPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        newPassword: event.newPassword,
        passwordRequirements: state.passwordRequirements.copyWith(
          length: event.newPassword.length > 5,
          number: RegExp(r'\d').hasMatch(event.newPassword),
          lowercase: RegExp(r'[a-z]').hasMatch(event.newPassword),
          uppercase: RegExp(r'[A-Z]').hasMatch(event.newPassword),
          specialChar: RegExp(r'[!-/:-@[-`{-~]').hasMatch(event.newPassword),
        ),
        errorMsg: '',
      ),
    );
  }

  void _onOldPasswordChanged(
    OldPasswordChanged event,
    Emitter<RecoverPasswordState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.oldPassword, errorMsg: ''));
  }

  void _onRecoverPasswordSubmit(
    RecoverPasswordSubmit event,
    Emitter<RecoverPasswordState> emit,
  ) async {
    if (!state.passwordRequirements.allSatisfied()) return;

    if (state.confirmPassword != state.newPassword) {
      emit(state.copyWith(errorMsg: 'The passwords do not match'));
      return;
    }

    final user = userRepository.get();

    if (user == null || user.password == null) return;

    await nextcloudService.updatePassword(
      PasswordUpdateRequestDto(
        oldPassword: user.password!,
        newPassword: state.newPassword,
      ),
      onComplete: (_) {
        user.password = null;
        user.iv = null;
        userRepository.update(user);
        getIt<SnackbarService>().showMessage('Password successfully updated');
        getIt<NavigationService>().resetToScreen(authRoute);
      },
      onFailed: (err) => _error(emit, ' '),
      onError: () => _error(emit, ' '),
    );
  }
}
