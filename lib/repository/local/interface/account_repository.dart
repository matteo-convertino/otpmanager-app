import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/local/interface/base_account_repository.dart';

abstract class AccountRepository extends BaseAccountRepository<Account> {
  bool alreadyExists(String secret);
  Account? getBySecret(String secret);
}
