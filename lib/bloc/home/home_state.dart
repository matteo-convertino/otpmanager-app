import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/user.dart';

import '../../utils/sync_status.dart';

class HomeState extends Equatable {
  final List<dynamic> accounts; // Account | SharedAccount
  final int refreshTime;
  final SyncStatus syncStatus;
  final String password;
  final bool isGuest;
  final bool? sortedByNameDesc;
  final bool? sortedByIssuerDesc;
  final bool? sortedByIdDesc;
  final String searchBarValue;
  final bool isAppUpdated;

  const HomeState({
    required this.accounts,
    required this.refreshTime,
    required this.syncStatus,
    required this.password,
    required this.isGuest,
    required this.sortedByNameDesc,
    required this.sortedByIssuerDesc,
    required this.sortedByIdDesc,
    required this.searchBarValue,
    required this.isAppUpdated,
  });

  HomeState.initial(User user)
    : accounts = [],
      refreshTime = 30,
      syncStatus = SyncStatus.loading,
      password = user.password ?? "",
      isGuest = user.isGuest,
      sortedByNameDesc = user.sortedByNameDesc,
      sortedByIssuerDesc = user.sortedByIssuerDesc,
      sortedByIdDesc = user.sortedByIdDesc,
      searchBarValue = "",
      isAppUpdated = false;

  HomeState copyWith({
    List<dynamic>? accounts,
    int? refreshTime,
    SyncStatus? syncStatus,
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
      password: password,
      isGuest: isGuest,
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
    sortedByNameDesc,
    sortedByIssuerDesc,
    sortedByIdDesc,
    searchBarValue,
    isAppUpdated,
  ];
}
