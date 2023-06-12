import 'package:equatable/equatable.dart';
import 'package:otp_manager/models/user.dart';

import '../../models/account.dart';

class AccountDetailsState extends Equatable {
  final Account account;
  final String accountDeleted;
  final String pin;

  const AccountDetailsState({
    required this.account,
    required this.accountDeleted,
    required this.pin,
  });

  AccountDetailsState.initial(this.account, User user)
      : accountDeleted = "",
        pin = user.pin ?? "";

  AccountDetailsState copyWith({String? accountDeleted}) {
    return AccountDetailsState(
      account: account,
      accountDeleted: accountDeleted ?? this.accountDeleted,
      pin: pin,
    );
  }

  @override
  List<Object> get props => [accountDeleted];
}
