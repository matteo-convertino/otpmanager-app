import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<SortByName>(_onSortByName);
    on<SortByIssuer>(_onSortByIssuer);
    on<SortById>(_onSortById);
    on<SearchBarValueChanged>(_onSearchBarValueChanged);

    add(NextcloudSync());
  }

  void _onNextcloudSync(NextcloudSync event, Emitter<HomeState> emit) async {
    add(GetAccounts());

    if (!state.isGuest) {
      emit(state.copyWith(syncStatus: 1));

      final Map<String, dynamic> result = await nextcloudService.sync();

      if (result["error"] != null) {
        emit(state.copyWith(syncStatus: -1, syncError: result["error"]));
        emit(state.copyWith(syncError: ""));
      } else if (result["toAdd"].length > 0 || result["toEdit"].length > 0) {
        if (nextcloudService.syncAccountsToAddToEdit(
            result["toAdd"], result["toEdit"])) {
          emit(state.copyWith(syncStatus: 0));
        } else {
          emit(state.copyWith(
            syncStatus: -1,
            syncError: "Password has changed. Insert the new one",
          ));
          emit(state.copyWith(syncError: ""));
          _navigationService.replaceScreen(authRoute);
        }
      } else {
        emit(state.copyWith(syncStatus: 0));
      }
    } else {
      emit(state.copyWith(syncStatus: -1));
    }

    add(GetAccounts());
  }

  void _onGetAccounts(GetAccounts event, Emitter<HomeState> emit) {
    if (state.searchBarValue == "") {
      emit(state.copyWith(
        accounts: localRepositoryImpl.getVisibleAccounts(),
      ));
    } else {
      emit(state.copyWith(
        accounts: localRepositoryImpl
            .getVisibleFilteredAccounts(state.searchBarValue),
      ));
    }
  }

  void _onLogout(Logout event, Emitter<HomeState> emit) {
    localRepositoryImpl.removeAllUsers();
    localRepositoryImpl.removeAllAccounts();
    _navigationService.resetToScreen(loginRoute);
  }

  void _onReorder(Reorder event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      sortedByIdDesc: "null",
      sortedByNameDesc: "null",
      sortedByIssuerDesc: "null",
    ));

    final user = localRepositoryImpl.getUser()!;
    user.sortedByNameDesc = state.sortedByNameDesc;
    user.sortedByIssuerDesc = state.sortedByIssuerDesc;
    user.sortedByIdDesc = state.sortedByIdDesc;
    localRepositoryImpl.updateUser(user);

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

    add(NextcloudSync());
  }

  void _onDeleteAccount(DeleteAccount event, Emitter<HomeState> emit) {
    if (localRepositoryImpl.setAccountAsDeleted(event.id)) {
      Account? accountDeleted = localRepositoryImpl.getAccount(event.id);

      add(NextcloudSync());

      emit(state.copyWith(
          accountDeleted:
              "${accountDeleted?.type.toUpperCase()} has been removed"));
    } else {
      emit(state.copyWith(
          accountDeleted: "There was an error while deleting the account"));
    }

    emit(state.copyWith(accountDeleted: ""));
    _navigationService.goBack();
  }

  void _onIncrementCounter(IncrementCounter event, Emitter<HomeState> emit) {
    event.account.counter = event.account.counter! + 1;
    event.account.toUpdate = true;
    localRepositoryImpl.updateAccount(event.account);
    add(NextcloudSync());
  }

  void _onSortById(SortById event, Emitter<HomeState> emit) {
    List<Account> accounts = localRepositoryImpl.getVisibleAccounts();

    if (state.sortedByIdDesc == null || state.sortedByIdDesc == true) {
      accounts.sort((b, a) => a.id.compareTo(b.id));
    } else {
      accounts.sort((a, b) => a.id.compareTo(b.id));
    }

    emit(state.copyWith(
      sortedByIdDesc:
          state.sortedByIdDesc == null ? false : !(state.sortedByIdDesc!),
      sortedByNameDesc: "null",
      sortedByIssuerDesc: "null",
    ));

    _updateSorting(accounts);
  }

  void _onSortByName(SortByName event, Emitter<HomeState> emit) {
    List<Account> accounts = localRepositoryImpl.getVisibleAccounts();

    if (state.sortedByNameDesc == null || state.sortedByNameDesc == true) {
      accounts.sort((a, b) => a.name.compareTo(b.name));
    } else {
      accounts.sort((b, a) => a.name.compareTo(b.name));
    }

    emit(state.copyWith(
      sortedByNameDesc:
          state.sortedByNameDesc == null ? false : !(state.sortedByNameDesc!),
      sortedByIdDesc: "null",
      sortedByIssuerDesc: "null",
    ));

    _updateSorting(accounts);
  }

  void _onSortByIssuer(SortByIssuer event, Emitter<HomeState> emit) {
    List<Account> accounts = localRepositoryImpl.getVisibleAccounts();

    if (state.sortedByIssuerDesc == null || state.sortedByIssuerDesc == true) {
      accounts.sort((a, b) => (a.issuer ?? "").compareTo(b.issuer ?? ""));
    } else {
      accounts.sort((b, a) => (a.issuer ?? "").compareTo(b.issuer ?? ""));
    }

    emit(state.copyWith(
      sortedByIssuerDesc: state.sortedByIssuerDesc == null
          ? false
          : !(state.sortedByIssuerDesc!),
      sortedByIdDesc: "null",
      sortedByNameDesc: "null",
    ));

    _updateSorting(accounts);
  }

  void _updateSorting(List<Account> accounts) {
    final user = localRepositoryImpl.getUser()!;
    user.sortedByNameDesc = state.sortedByNameDesc;
    user.sortedByIssuerDesc = state.sortedByIssuerDesc;
    user.sortedByIdDesc = state.sortedByIdDesc;
    localRepositoryImpl.updateUser(user);

    for (int i = 0; i < accounts.length; i++) {
      accounts[i].position = i;
      accounts[i].toUpdate = true;
      localRepositoryImpl.updateAccount(accounts[i]);
    }

    add(NextcloudSync());
  }

  void _onSearchBarValueChanged(
      SearchBarValueChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(searchBarValue: event.value));
  }
}
