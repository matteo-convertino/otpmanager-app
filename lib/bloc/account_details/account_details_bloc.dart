import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/account_details/account_details_event.dart';
import 'package:otp_manager/bloc/account_details/account_details_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';

import '../../routing/navigation_service.dart';

@injectable
class AccountDetailsBloc
    extends Bloc<AccountDetailsEvent, AccountDetailsState> {
  final UserRepository userRepository;
  final AccountRepository accountRepository;
  final AccountService accountService;
  final SharedAccountRepository sharedAccountRepository;
  final Object account; // Account | SharedAccount

  final NavigationService _navigationService = NavigationService();

  AccountDetailsBloc({
    required this.userRepository,
    required this.accountRepository,
    required this.accountService,
    required this.sharedAccountRepository,
    @factoryParam required this.account,
  }) : super(AccountDetailsState.initial(account, userRepository.get()!)) {
    on<DeleteAccount>(_onDeleteAccount);
  }

  void _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountDetailsState> emit,
  ) {
    accountService.setAsDeleted(state.account);

    getIt<SnackbarService>().showMessage(
      "${state.account.type.toUpperCase()} has been removed",
    );

    _navigationService.resetToScreen(homeRoute);
  }
}
