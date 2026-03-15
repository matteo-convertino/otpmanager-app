import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_event.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_state.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';

@injectable
class OtpManagerBloc extends Bloc<OtpManagerEvent, OtpManagerState> {
  final UserRepository userRepository;
  final AccountRepository accountRepository;
  final SharedAccountRepository sharedAccountRepository;
  final NavigationService navigationService;

  OtpManagerBloc({
    required this.userRepository,
    required this.accountRepository,
    required this.sharedAccountRepository,
    required this.navigationService,
  }) : super(
         OtpManagerState.initial(
           userRepository.get(),
           userRepository.isLogged(),
         ),
       ) {
    on<Logout>(_onLogout);
    on<CopyWithTapToggled>(_onCopyWithTapToggled);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<OpenSearchBarOnStartupToggled>(_onOpenSearchBarOnStartupToggled);
    on<ClickToRevealCodesToggled>(_onClickToRevealCodesToggled);
    on<BlackThemeToggled>(_onBlackThemeToggled);
  }

  void _onLogout(Logout event, Emitter<OtpManagerState> emit) {
    userRepository.removeAll();
    accountRepository.removeAll();
    sharedAccountRepository.removeAll();
    emit(OtpManagerState.initial(null, false));
    navigationService.resetToScreen(loginRoute);
  }

  void _onCopyWithTapToggled(
    CopyWithTapToggled event,
    Emitter<OtpManagerState> emit,
  ) {
    final user = userRepository.get();
    user?.copyWithTap = !user.copyWithTap;
    userRepository.update(user!);
    emit(state.copyWith(copyWithTap: user.copyWithTap));
  }

  void _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<OtpManagerState> emit,
  ) {
    final user = userRepository.get()!;
    user.themeMode = event.themeMode;
    userRepository.update(user);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onOpenSearchBarOnStartupToggled(
    OpenSearchBarOnStartupToggled event,
    Emitter<OtpManagerState> emit,
  ) {
    final user = userRepository.get();
    user?.openSearchBarOnStartup = !user.openSearchBarOnStartup;
    userRepository.update(user!);
    emit(state.copyWith(openSearchBarOnStartup: user.openSearchBarOnStartup));
  }

  void _onClickToRevealCodesToggled(
    ClickToRevealCodesToggled event,
    Emitter<OtpManagerState> emit,
  ) {
    final user = userRepository.get();
    user?.clickToRevealCodes = !user.clickToRevealCodes;
    userRepository.update(user!);
    emit(state.copyWith(clickToRevealCodes: user.clickToRevealCodes));
  }

  void _onBlackThemeToggled(
    BlackThemeToggled event,
    Emitter<OtpManagerState> emit,
  ) {
    final user = userRepository.get();
    user?.blackTheme = !user.blackTheme;
    userRepository.update(user!);
    emit(state.copyWith(blackTheme: user.blackTheme));
  }
}
