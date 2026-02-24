import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/bloc/home/home_state.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/local/interface/account_repository.dart';
import 'package:otp_manager/repository/local/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/service/account_service.dart';
import 'package:otp_manager/service/nextcloud_service.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/optional.dart';
import 'package:otp_manager/utils/sync_status.dart';

import '../../models/shared_account.dart';
import '../../routing/navigation_service.dart';
import '../../service/encryption_service.dart';

@lazySingleton
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final AccountRepository accountRepository;
  final AccountService accountService;
  final SharedAccountRepository sharedAccountRepository;
  final EncryptionService encryption;
  final NextcloudService nextcloudService;
  final NavigationService navigationService;

  HomeBloc({
    required this.userRepository,
    required this.accountRepository,
    required this.accountService,
    required this.sharedAccountRepository,
    required this.encryption,
    required this.nextcloudService,
    required this.navigationService,
  }) : super(HomeState.initial(userRepository.get()!)) {
    on<NextcloudSync>(_onNextcloudSync);
    on<GetAccounts>(_onGetAccounts);
    on<Logout>(_onLogout);
    on<Reorder>(_onReorder);
    on<DeleteAccount>(_onDeleteAccount);
    on<SortByName>(_onSortByName);
    on<SortByIssuer>(_onSortByIssuer);
    on<SortById>(_onSortById);
    on<SearchBarValueChanged>(_onSearchBarValueChanged);
    on<IsAppUpdatedChanged>(_onIsAppUpdatedChanged);

    add(NextcloudSync());
  }

  void _onIsAppUpdatedChanged(
    IsAppUpdatedChanged event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isAppUpdated: event.value));
  }

  void _onNextcloudSync(NextcloudSync event, Emitter<HomeState> emit) async {
    add(GetAccounts());

    if (state.isGuest) {
      emit(state.copyWith(syncStatus: SyncStatus.error));
      return;
    }

    emit(state.copyWith(syncStatus: SyncStatus.loading));

    await nextcloudService.sync(
      onFailed: (err) => emit(state.copyWith(syncStatus: SyncStatus.error)),
      onError: () => emit(state.copyWith(syncStatus: SyncStatus.error)),
    );

    emit(state.copyWith(syncStatus: SyncStatus.success));

    add(GetAccounts());
  }

  List mergeResults(
    List<Account> accounts,
    List<SharedAccount> sharedAccounts,
  ) {
    List result = [...accounts, ...sharedAccounts];

    result.sort((a, b) => a.position.compareTo(b.position));

    return result;
  }

  void _onGetAccounts(GetAccounts event, Emitter<HomeState> emit) {
    if (state.searchBarValue.isEmpty) {
      emit(
        state.copyWith(
          accounts: mergeResults(
            accountRepository.getVisible(),
            sharedAccountRepository.getVisible(),
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          accounts: mergeResults(
            accountRepository.getVisibleFiltered(state.searchBarValue),
            sharedAccountRepository.getVisibleFiltered(state.searchBarValue),
          ),
        ),
      );
    }
  }

  void _onLogout(Logout event, Emitter<HomeState> emit) {
    userRepository.removeAll();
    accountRepository.removeAll();
    sharedAccountRepository.removeAll();
    navigationService.resetToScreen(loginRoute);
  }

  void _onReorder(Reorder event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        sortedByIdDesc: Optional(null),
        sortedByNameDesc: Optional(null),
        sortedByIssuerDesc: Optional(null),
      ),
    );

    final user = userRepository.get()!;
    user.sortedByNameDesc = state.sortedByNameDesc;
    user.sortedByIssuerDesc = state.sortedByIssuerDesc;
    user.sortedByIdDesc = state.sortedByIdDesc;
    userRepository.update(user);

    accountService.reorder(event.oldIndex, event.newIndex);

    add(NextcloudSync());
  }

  void _onDeleteAccount(DeleteAccount event, Emitter<HomeState> emit) {
    if (event.account != null) {
      accountService.setAsDeleted(event.account);

      add(NextcloudSync());

      getIt<SnackbarService>().showMessage(
        '${event.account.type.toUpperCase()} has been removed',
      );
    } else {
      getIt<SnackbarService>().showMessage(
        'There was an error while deleting the account',
      );
    }

    navigationService.goBack();
  }

  void _onSortById(SortById event, Emitter<HomeState> emit) {
    List<Account> accounts = accountRepository.getVisible();

    if (state.sortedByIdDesc == null || state.sortedByIdDesc == true) {
      accounts.sort((b, a) => a.id.compareTo(b.id));
    } else {
      accounts.sort((a, b) => a.id.compareTo(b.id));
    }

    emit(
      state.copyWith(
        sortedByIdDesc: state.sortedByIdDesc == null
            ? Optional(false)
            : Optional(!(state.sortedByIdDesc!)),
        sortedByNameDesc: Optional(null),
        sortedByIssuerDesc: Optional(null),
      ),
    );

    _updateSorting(accounts);
  }

  void _onSortByName(SortByName event, Emitter<HomeState> emit) {
    List<Account> accounts = accountRepository.getVisible();

    if (state.sortedByNameDesc == null || state.sortedByNameDesc == true) {
      accounts.sort((a, b) => a.name.compareTo(b.name));
    } else {
      accounts.sort((b, a) => a.name.compareTo(b.name));
    }

    emit(
      state.copyWith(
        sortedByNameDesc: state.sortedByNameDesc == null
            ? Optional(false)
            : Optional(!(state.sortedByNameDesc!)),
        sortedByIdDesc: Optional(null),
        sortedByIssuerDesc: Optional(null),
      ),
    );

    _updateSorting(accounts);
  }

  void _onSortByIssuer(SortByIssuer event, Emitter<HomeState> emit) {
    List<Account> accounts = accountRepository.getVisible();

    if (state.sortedByIssuerDesc == null || state.sortedByIssuerDesc == true) {
      accounts.sort((a, b) => (a.issuer ?? '').compareTo(b.issuer ?? ''));
    } else {
      accounts.sort((b, a) => (a.issuer ?? '').compareTo(b.issuer ?? ''));
    }

    emit(
      state.copyWith(
        sortedByIssuerDesc: state.sortedByIssuerDesc == null
            ? Optional(false)
            : Optional(!(state.sortedByIssuerDesc!)),
        sortedByIdDesc: Optional(null),
        sortedByNameDesc: Optional(null),
      ),
    );

    _updateSorting(accounts);
  }

  void _updateSorting(List<Account> accounts) {
    final user = userRepository.get()!;
    user.sortedByNameDesc = state.sortedByNameDesc;
    user.sortedByIssuerDesc = state.sortedByIssuerDesc;
    user.sortedByIdDesc = state.sortedByIdDesc;
    userRepository.update(user);

    for (int i = 0; i < accounts.length; i++) {
      accounts[i].position = i;
      accountRepository.update(accounts[i]);
    }

    add(NextcloudSync());
  }

  void _onSearchBarValueChanged(
    SearchBarValueChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(searchBarValue: event.value));
  }
}
