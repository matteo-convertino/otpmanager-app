import 'package:injectable/injectable.dart' hide Order;
import 'package:logger/logger.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/object_box/objectbox.g.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';

import '../interface/shared_account_repository.dart';

@LazySingleton(as: SharedAccountRepository)
class SharedAccountRepositoryImpl extends SharedAccountRepository {
  final _logger = getIt<Logger>();

  @override
  void addNew(List<SharedAccount> sharedAccounts) {
    _logger.d('SharedAccountRepositoryImpl._addNew start');

    for (var sharedAccount in sharedAccounts) {
      String iconKey = 'default';
      bool toUpdate = false;

      if (sharedAccount.iconKey != 'default') {
        iconKey = sharedAccount.iconKey;
      } else if (sharedAccount.issuer != null &&
          sharedAccount.issuer!.isNotEmpty) {
        iconKey = OtpIconsHelper.findFirst(sharedAccount.issuer!);
        toUpdate = iconKey != 'default';
      }

      sharedAccount.iconKey = iconKey;
      sharedAccount.toUpdate = toUpdate;

      super.box.put(sharedAccount);
    }
  }

  @override
  void updateEdited(List<SharedAccount> sharedAccounts) {
    _logger.d('SharedAccountRepositoryImpl._updateEdited start');

    for (var sharedAccount in sharedAccounts) {
      SharedAccount? sharedAccountToUpdate = super.box
          .query(
            SharedAccount_.nextcloudAccountId.equals(
              sharedAccount.nextcloudAccountId,
            ),
          )
          .build()
          .findFirst();

      sharedAccountToUpdate?.name = sharedAccount.name;
      sharedAccountToUpdate?.issuer = sharedAccount.issuer;
      sharedAccountToUpdate?.secret = sharedAccount.secret;
      sharedAccountToUpdate?.encryptedSecret = sharedAccount.encryptedSecret;
      sharedAccountToUpdate?.unlocked = sharedAccount.unlocked;
      sharedAccountToUpdate?.counter = sharedAccount.counter;
      sharedAccountToUpdate?.expiredAt = sharedAccount.expiredAt;
      sharedAccountToUpdate?.iconKey = sharedAccount.iconKey;
      sharedAccountToUpdate?.position = sharedAccount.position;

      super.box.put(sharedAccountToUpdate!);
    }
  }

  @override
  List<SharedAccount> getVisible() {
    return (super.box.query(
      SharedAccount_.deleted.equals(false),
    )..order(SharedAccount_.position)).build().find();
  }

  @override
  List<SharedAccount> getVisibleFiltered(String filter) {
    return (super.box.query(
      SharedAccount_.deleted.equals(false) &
          (SharedAccount_.name.contains(filter, caseSensitive: false) |
              SharedAccount_.issuer.contains(filter, caseSensitive: false)),
    )..order(SharedAccount_.position)).build().find();
  }

  @override
  void deleteOld(List<int> nextcloudAccountIds) {
    _logger.d('SharedAccountRepositoryImpl._deleteOld start');

    super.box
        .query(SharedAccount_.deleted.equals(true))
        .build()
        .find()
        .forEach((SharedAccount account) => super.box.remove(account.id));

    for (var id in nextcloudAccountIds) {
      super.box.remove(id);
    }
  }

  @override
  void updateNeverSync() {
    _logger.d('SharedAccountRepositoryImpl._updateNeverSync start');

    super.box
        .query(SharedAccount_.toUpdate.equals(true))
        .build()
        .find()
        .forEach((SharedAccount account) {
          account.toUpdate = false;
          super.box.put(account);
        });
  }

  @override
  void scalePositionAfter(int position) {
    super.box
        .query(
          SharedAccount_.deleted.equals(false) &
              SharedAccount_.position.greaterThan(position),
        )
        .build()
        .find()
        .forEach((sharedAccount) {
          sharedAccount.position = sharedAccount.position! - 1;
          update(sharedAccount);
        });
  }

  @override
  int getLastPosition() {
    SharedAccount? lastAccount =
        (super.box.query(SharedAccount_.deleted.equals(false))
              ..order(SharedAccount_.position, flags: Order.descending))
            .build()
            .findFirst();

    return lastAccount == null ? -1 : lastAccount.position!;
  }

  @override
  List<SharedAccount> getBetweenPositions(int min, int max) {
    return super.box
        .query(
          SharedAccount_.deleted.equals(false) &
              SharedAccount_.position.greaterThan(min) &
              SharedAccount_.position.lessOrEqual(max),
        )
        .build()
        .find();
  }

  @override
  SharedAccount? getByPosition(int position) {
    return super.box
        .query(SharedAccount_.position.equals(position))
        .build()
        .findFirst();
  }
}
