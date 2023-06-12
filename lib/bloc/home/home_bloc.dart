import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp/otp.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/bloc/home/home_state.dart';
import 'package:otp_manager/domain/nextcloud_service.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';

import '../../routing/navigation_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LocalRepositoryImpl localRepositoryImpl;
  final NextcloudService nextcloudService;

  final NavigationService _navigationService = NavigationService();

  HomeBloc({
    required this.localRepositoryImpl,
    required this.nextcloudService,
  }) : super(
          HomeState.initial(localRepositoryImpl.getUser()!),
        ) {
    on<NextcloudSync>(_onNextcloudSync);
    on<GetAccounts>(_onGetAccounts);
    on<Logout>(_onLogout);
    on<Reorder>(_onReorder);
    on<DeleteAccount>(_onDeleteAccount);
    on<IncrementCounter>(_onIncrementCounter);
  }

  String? _getOtp(Account account) {
    if (account.type == "totp") {
      return OTP.generateTOTPCodeString(
        account.secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: account.algorithm,
        interval: account.period as int,
        length: account.digits as int,
        isGoogle: true,
      );
    } else if (account.counter! > 0) {
      return OTP.generateHOTPCodeString(
        account.secret,
        account.counter!,
        algorithm: account.algorithm,
        length: account.digits as int,
        isGoogle: true,
      );
    }
    return null;
  }

  void _emitAccountsWithCode(List<Account> accounts, Emitter<HomeState> emit) {
    final Map<Account, String?> accountsWithCode = {};

    for (var account in accounts) {
      accountsWithCode[account] = _getOtp(account);
    }

    emit(state.copyWith(accounts: accountsWithCode));
  }

  void _onNextcloudSync(NextcloudSync event, Emitter<HomeState> emit) async {
    if (!state.isGuest) {
      emit(state.copyWith(syncStatus: 1));

      final error = await nextcloudService.sync();

      if (error == null) {
        emit(state.copyWith(syncStatus: 0));
      } else {
        emit(state.copyWith(syncStatus: -1, syncError: error));
        emit(state.copyWith(syncError: ""));
      }
    } else {
      emit(state.copyWith(syncStatus: -1));
    }

    _emitAccountsWithCode(localRepositoryImpl.getVisibleAccounts(), emit);
  }

  void _onGetAccounts(GetAccounts event, Emitter<HomeState> emit) {
    if (event.filter == "") {
      _emitAccountsWithCode(localRepositoryImpl.getVisibleAccounts(), emit);
    } else {
      _emitAccountsWithCode(
          localRepositoryImpl.getVisibleFilteredAccounts(event.filter), emit);
    }
  }

  void _onLogout(Logout event, Emitter<HomeState> emit) {
    localRepositoryImpl.removeAllUsers();
    localRepositoryImpl.removeAllAccounts();
    _navigationService.resetToScreen(loginRoute);
  }

  void _onReorder(Reorder event, Emitter<HomeState> emit) {
    List<Account> accountsBetween;

    int difference;
    int newIndex = event.newIndex;

    if (event.newIndex > event.oldIndex) {
      newIndex -= 1;
      accountsBetween = localRepositoryImpl.getAccountBetweenPositions(
          event.oldIndex, newIndex);
      difference = -1;
    } else {
      accountsBetween = localRepositoryImpl.getAccountBetweenPositions(
          event.newIndex - 1, event.oldIndex - 1);
      difference = 1;
    }

    var account = localRepositoryImpl.getAccountByPosition(event.oldIndex);

    for (var account in accountsBetween) {
      account.position = account.position! + difference;
      account.toUpdate = true;
      localRepositoryImpl.updateAccount(account);
    }

    account?.position = newIndex;
    account?.toUpdate = true;
    localRepositoryImpl.updateAccount(account!);
    add(const GetAccounts());
    add(NextcloudSync());
  }

  void _onDeleteAccount(DeleteAccount event, Emitter<HomeState> emit) {
    if(localRepositoryImpl.setAccountAsDeleted(event.id)) {
      Account? accountDeleted = localRepositoryImpl.getAccount(event.id);

      add(const GetAccounts());
      add(NextcloudSync());

      emit(state.copyWith(
          accountDeleted:
          "${accountDeleted?.type == "totp" ? "TOTP" : "HOTP"} has been removed"));
    } else {
      emit(state.copyWith(
          accountDeleted:
          "There was an error while deleting the account"));
    }

    emit(state.copyWith(accountDeleted: ""));
    _navigationService.goBack();
  }

  void _onIncrementCounter(IncrementCounter event, Emitter<HomeState> emit) {
    event.account.counter = event.account.counter! + 1;
    event.account.toUpdate = true;
    localRepositoryImpl.updateAccount(event.account);
    add(const GetAccounts());
    add(NextcloudSync());
  }
}
