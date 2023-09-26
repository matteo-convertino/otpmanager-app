import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/models/user.dart';

class HomeState extends Equatable {
  final Map<Account, String?> accounts;
  final int refreshTime;
  final int syncStatus; // 1 = SYNCING, 0 = OK, -1 = ERROR
  final String syncError;
  final String pin;
  final bool isGuest;
  final String accountDeleted;
  final bool sortedByNameDesc;
  final bool sortedByIssuerDesc;
  final bool sortedByIdDesc;
  final String searchBarValue;

  const HomeState({
    required this.accounts,
    required this.refreshTime,
    required this.syncStatus,
    required this.syncError,
    required this.pin,
    required this.isGuest,
    required this.accountDeleted,
    required this.sortedByNameDesc,
    required this.sortedByIssuerDesc,
    required this.sortedByIdDesc,
    required this.searchBarValue,
  });

  HomeState.initial(User user)
      : accounts = {},
        refreshTime = 30,
        syncStatus = 1,
        syncError = "",
        pin = user.pin ?? "",
        isGuest = user.isGuest,
        accountDeleted = "",
        sortedByNameDesc = true,
        sortedByIssuerDesc = true,
        sortedByIdDesc = true,
        searchBarValue = "";

  HomeState copyWith({
    Map<Account, String?>? accounts,
    int? refreshTime,
    int? syncStatus,
    String? syncError,
    String? accountDeleted,
    bool? sortedByNameDesc,
    bool? sortedByIssuerDesc,
    bool? sortedByIdDesc,
    String? searchBarValue,
  }) {
    return HomeState(
      accounts: accounts ?? this.accounts,
      refreshTime: refreshTime ?? this.refreshTime,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      pin: pin,
      isGuest: isGuest,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      sortedByNameDesc: sortedByNameDesc ?? this.sortedByNameDesc,
      sortedByIssuerDesc: sortedByIssuerDesc ?? this.sortedByIssuerDesc,
      sortedByIdDesc: sortedByIdDesc ?? this.sortedByIdDesc,
      searchBarValue: searchBarValue ?? this.searchBarValue,
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
        searchBarValue
      ];
}
