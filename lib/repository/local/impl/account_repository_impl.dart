import 'package:injectable/injectable.dart' hide Order;
import 'package:logger/logger.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/object_box/objectbox.g.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';

import '../../../di/injection.dart';
import '../interface/account_repository.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl extends AccountRepository {
  final _logger = getIt<Logger>();

  @override
  void addNew(List<Account> accounts) {
    _logger.d('AccountRepositoryImpl._addNew start');

    for (var account in accounts) {
      String iconKey = 'default';
      bool toUpdate = false;

      if (account.iconKey != 'default') {
        iconKey = account.iconKey;
      } else if (account.issuer != null && account.issuer!.isNotEmpty) {
        iconKey = OtpIconsHelper.findFirst(account.issuer!);
        toUpdate = iconKey != 'default';
      }

      account.iconKey = iconKey;
      account.toUpdate = toUpdate;
      account.isNew = false;

      super.box.put(account);
    }
  }

  @override
  void updateEdited(List<Account> accounts) {
    _logger.d('AccountRepositoryImpl._updateEdited start');

    for (var account in accounts) {
      Account? accountToUpdate = super.box
          .query(Account_.secret.equals(account.secret))
          .build()
          .findFirst();

      accountToUpdate?.name = account.name;
      accountToUpdate?.issuer = account.issuer;
      accountToUpdate?.digits = account.digits;
      accountToUpdate?.type = account.type;
      accountToUpdate?.dbAlgorithm = account.dbAlgorithm;
      accountToUpdate?.period = account.period;
      accountToUpdate?.counter = account.counter;
      accountToUpdate?.iconKey = account.iconKey;
      accountToUpdate?.position = account.position;
      super.box.put(accountToUpdate!);
    }
  }

  @override
  bool alreadyExists(String secret) {
    return super.box
        .query(Account_.secret.equals(secret))
        .build()
        .find()
        .isNotEmpty;
  }

  @override
  void deleteOld(List nextcloudAccountIds) {
    _logger.d('AccountRepositoryImpl._deleteOld start');

    super.box
        .query(Account_.deleted.equals(true))
        .build()
        .find()
        .forEach((Account account) => super.box.remove(account.id));

    for (var id in nextcloudAccountIds) {
      super.box.remove(id);
    }
  }

  @override
  void updateNeverSync() {
    _logger.d('AccountRepositoryImpl._updateNeverSync start');

    super.box
        .query(Account_.toUpdate.equals(true) | Account_.isNew.equals(true))
        .build()
        .find()
        .forEach((Account account) {
          account.isNew = false;
          account.toUpdate = false;
          super.box.put(account);
        });
  }

  @override
  List<Account> getVisible() {
    return (super.box.query(
      Account_.deleted.equals(false),
    )..order(Account_.position)).build().find();
  }

  @override
  List<Account> getVisibleFiltered(String filter) {
    return (super.box.query(
      Account_.deleted.equals(false) &
          (Account_.name.contains(filter, caseSensitive: false) |
              Account_.issuer.contains(filter, caseSensitive: false)),
    )..order(Account_.position)).build().find();
  }

  @override
  Account? getBySecret(String secret) {
    return super.box.query(Account_.secret.equals(secret)).build().findFirst();
  }

  @override
  void scalePositionAfter(int position) {
    super.box
        .query(
          Account_.deleted.equals(false) &
              Account_.position.greaterThan(position),
        )
        .build()
        .find()
        .forEach((account) {
          account.position = account.position! - 1;
          account.toUpdate = true;
          super.box.put(account);
        });
  }

  @override
  List<Account> getBetweenPositions(int min, int max) {
    return super.box
        .query(
          Account_.deleted.equals(false) &
              Account_.position.greaterThan(min) &
              Account_.position.lessOrEqual(max),
        )
        .build()
        .find();
  }

  @override
  Account? getByPosition(int position) {
    return super.box
        .query(Account_.position.equals(position))
        .build()
        .findFirst();
  }

  @override
  int getLastPosition() {
    Account? lastAccount = (super.box.query(
      Account_.deleted.equals(false),
    )..order(Account_.position, flags: Order.descending)).build().findFirst();

    return lastAccount == null ? -1 : lastAccount.position!;
  }
}
