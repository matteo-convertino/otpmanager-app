import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/models/user.dart';

class HomeState extends Equatable {
  final List<Account> accounts;
  final int refreshTime;
  final int syncStatus; // 1 = SYNCING, 0 = OK, -1 = ERROR
  final String syncError;
  final String password;
  final bool isGuest;
  final String accountDeleted;
  final bool? sortedByNameDesc;
  final bool? sortedByIssuerDesc;
  final bool? sortedByIdDesc;
  final String searchBarValue;
  final bool isAppUpdated;

  const HomeState({
    required this.accounts,
    required this.refreshTime,
    required this.syncStatus,
    required this.syncError,
    required this.password,
    required this.isGuest,
    required this.accountDeleted,
    required this.sortedByNameDesc,
    required this.sortedByIssuerDesc,
    required this.sortedByIdDesc,
    required this.searchBarValue,
    required this.isAppUpdated,
  });

  HomeState.initial(User user)
      : accounts = [],
        refreshTime = 30,
        syncStatus = 1,
        syncError = "",
        password = user.password ?? "",
        isGuest = user.isGuest,
        accountDeleted = "",
        sortedByNameDesc = user.sortedByNameDesc,
        sortedByIssuerDesc = user.sortedByIssuerDesc,
        sortedByIdDesc = user.sortedByIdDesc,
        searchBarValue = "",
        isAppUpdated = false;

  HomeState copyWith({
    List<Account>? accounts,
    int? refreshTime,
    int? syncStatus,
    String? syncError,
    String? accountDeleted,
    dynamic sortedByNameDesc,
    dynamic sortedByIssuerDesc,
    dynamic sortedByIdDesc,
    String? searchBarValue,
    bool? isAppUpdated,
  }) {
    return HomeState(
      accounts: accounts ?? this.accounts,
      refreshTime: refreshTime ?? this.refreshTime,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      password: password,
      isGuest: isGuest,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      sortedByNameDesc: sortedByNameDesc == "null"
          ? null
          : sortedByNameDesc ?? this.sortedByNameDesc,
      sortedByIssuerDesc: sortedByIssuerDesc == "null"
          ? null
          : sortedByIssuerDesc ?? this.sortedByIssuerDesc,
      sortedByIdDesc: sortedByIdDesc == "null"
          ? null
          : sortedByIdDesc ?? this.sortedByIdDesc,
      searchBarValue: searchBarValue ?? this.searchBarValue,
      isAppUpdated: isAppUpdated ?? this.isAppUpdated,
    );
  }

  @override
  List<Object?> get props => [
        accounts,
        refreshTime,
        syncStatus,
        syncError,
        accountDeleted,
        sortedByNameDesc,
        sortedByIssuerDesc,
        sortedByIdDesc,
        searchBarValue,
        isAppUpdated,
      ];
}
