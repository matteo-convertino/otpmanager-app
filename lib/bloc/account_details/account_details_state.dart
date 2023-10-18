import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/user.dart';

import '../../models/account.dart';

class AccountDetailsState extends Equatable {
  final Account account;
  final String accountDeleted;
  final String password;

  const AccountDetailsState({
    required this.account,
    required this.accountDeleted,
    required this.password,
  });

  AccountDetailsState.initial(this.account, User user)
      : accountDeleted = "",
        password = user.password ?? "";

  AccountDetailsState copyWith({String? accountDeleted}) {
    return AccountDetailsState(
      account: account,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      password: password,
    );
  }

  @override
  List<Object> get props => [accountDeleted];
}
