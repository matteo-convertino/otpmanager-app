import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_event.dart';
import 'package:otp_manager/bloc/account_details/account_details_state.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';

import '../../routing/navigation_service.dart';

class AccountDetailsBloc
    extends Bloc<AccountDetailsEvent, AccountDetailsState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final Account account;

  final NavigationService _navigationService = NavigationService();

  AccountDetailsBloc({
    required this.localRepositoryImpl,
    required this.account,
  }) : super(
          AccountDetailsState.initial(account, localRepositoryImpl.getUser()!),
        ) {
    on<DeleteAccount>(_onDeleteAccount);
  }

  void _onDeleteAccount(
      DeleteAccount event, Emitter<AccountDetailsState> emit) {
    if (localRepositoryImpl.setAccountAsDeleted(state.account.id)) {
      emit(state.copyWith(
          accountDeleted:
              "${state.account.type == "totp" ? "TOTP" : "HOTP"} has been removed"));
      _navigationService.resetToScreen(homeRoute);
    } else {
      emit(state.copyWith(
          accountDeleted: "There was an error while deleting the account"));
      _navigationService.goBack();
    }
  }
}
