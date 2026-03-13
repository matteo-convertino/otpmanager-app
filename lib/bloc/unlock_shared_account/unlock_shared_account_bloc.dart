import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_event.dart';
import 'package:otp_manager/bloc/unlock_shared_account/unlock_shared_account_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/dto/request/shared_account_unlock_request_dto.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../home/home_bloc.dart';

@injectable
class UnlockSharedAccountBloc
    extends Bloc<UnlockSharedAccountEvent, UnlockSharedAccountState> {
  final NextcloudService nextcloudService;
  final SharedAccountRepository sharedAccountRepository;
  final UserRepository userRepository;
  final HomeBloc homeBloc;

  final int accountId;

  UnlockSharedAccountBloc({
    required this.sharedAccountRepository,
    required this.nextcloudService,
    required this.userRepository,
    required this.homeBloc,
    @factoryParam required this.accountId,
  }) : super(const UnlockSharedAccountState.initial()) {
    on<PasswordSubmit>(_onPasswordSubmit);
    on<PasswordChanged>(_onPasswordChanged);
    on<ResetAttempts>(_onResetAttempts);
  }

  void _onResetAttempts(
    ResetAttempts event,
    Emitter<UnlockSharedAccountState> emit,
  ) {
    emit(state.copyWith(attempts: 3));
  }

  void _onPasswordChanged(
    PasswordChanged event,
    Emitter<UnlockSharedAccountState> emit,
  ) {
    emit(state.copyWith(password: event.password, errorMsg: ''));
  }

  void _error(Emitter<UnlockSharedAccountState> emit, String msg) {
    emit(state.copyWith(errorMsg: msg, attempts: state.attempts - 1));

    if (state.attempts == 0) {
      emit(state.copyWith(attempts: 3));
    }
  }

  void _onPasswordSubmit(
    PasswordSubmit event,
    Emitter<UnlockSharedAccountState> emit,
  ) async {
    if (state.password.isEmpty) {
      emit(state.copyWith(errorMsg: 'Password cannot be empty'));
      return;
    }

    await nextcloudService.unlockSharedAccount(
      SharedAccountUnlockRequestDto(
        accountId: accountId,
        currentPassword: userRepository.get()!.password!,
        tempPassword: state.password,
      ),
      onComplete: (_) {
        emit(state.copyWith(isCorrectPassword: true));
        getIt<SnackbarService>().showMessage(
          'Shared account unlocked with success',
        );
        homeBloc.add(NextcloudSync());
      },
      onFailed: (err) => _error(emit, ' '),
      onError: () => _error(emit, ' '),
    );
  }
}
