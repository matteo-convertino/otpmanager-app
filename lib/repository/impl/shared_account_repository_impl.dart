import 'package:otp_manager/models/shared_account.dart';
import 'package:otp_manager/object_box/objectbox.g.dart';
import 'package:otp_manager/utils/icon_picker_helper.dart';

import '../../main.dart' show logger;
import '../interface/shared_account_repository.dart';

class SharedAccountRepositoryImpl extends SharedAccountRepository {
  @override
  void addNew(List nextcloudAccounts) {
    logger.d("SharedAccountRepositoryImpl._addNew start");

    for (var sharedAccount in nextcloudAccounts) {
      String iconKey = "default";

      if (sharedAccount["icon"] != null && sharedAccount["icon"] != "default") {
        iconKey = sharedAccount["icon"];
      } else if (sharedAccount["issuer"] != null &&
          sharedAccount["issuer"] != "") {
        iconKey = IconPickerHelper.findFirst(sharedAccount["issuer"]);
      }

      super.box.put(
            SharedAccount(
              name: sharedAccount["name"],
              issuer: sharedAccount["issuer"],
              secret: sharedAccount["secret"],
              encryptedSecret: sharedAccount["encryptedSecret"],
              iconKey: iconKey,
              position: sharedAccount["position"],
              toUpdate: iconKey != "default",
              password: sharedAccount["password"],
              iv: sharedAccount["iv"],
              nextcloudAccountId: sharedAccount["account_id"],
              expiredAt: sharedAccount["expired_at"] != null
                  ? DateTime.parse(sharedAccount["expired_at"])
                  : null,
              period: sharedAccount["period"],
              digits: sharedAccount["digits"],
              type: sharedAccount["type"],
              counter: sharedAccount["counter"],
              dbAlgorithm: sharedAccount["algorithm"],
              unlocked: sharedAccount["unlocked"] == 1 ||
                  sharedAccount["unlocked"] == true,
              sharerUserId: sharedAccount["user_id"],
            ),
          );
    }
  }

  @override
  void updateEdited(List nextcloudAccounts) {
    logger.d("SharedAccountRepositoryImpl._updateEdited start");

    for (var sharedAccount in nextcloudAccounts) {
      SharedAccount? sharedAccountToUpdate = super
          .box
          .query(SharedAccount_.nextcloudAccountId
              .equals(sharedAccount["account_id"]))
          .build()
          .findFirst();

      sharedAccountToUpdate?.name = sharedAccount["name"];
      sharedAccountToUpdate?.issuer = sharedAccount["issuer"];
      sharedAccountToUpdate?.secret = sharedAccount["secret"];
      sharedAccountToUpdate?.encryptedSecret = sharedAccount["encryptedSecret"];
      sharedAccountToUpdate?.unlocked =
          sharedAccount["unlocked"] == 1 || sharedAccount["unlocked"] == true;
      sharedAccountToUpdate?.counter = sharedAccount["counter"];
      sharedAccountToUpdate?.expiredAt = sharedAccount["expired_at"] != null
          ? DateTime.parse(sharedAccount["expired_at"])
          : null;
      sharedAccountToUpdate?.iconKey =
          sharedAccount["icon"] ?? sharedAccountToUpdate.iconKey;
      sharedAccountToUpdate?.position = sharedAccount["position"];

      super.box.put(sharedAccountToUpdate!);
    }
  }

  @override
  List<SharedAccount> getVisible() {
    return (super.box.query(SharedAccount_.deleted.equals(false))
          ..order(SharedAccount_.position))
        .build()
        .find();
  }

  @override
  List<SharedAccount> getVisibleFiltered(String filter) {
    return (super.box.query(SharedAccount_.deleted.equals(false) &
            (SharedAccount_.name.contains(filter, caseSensitive: false) |
                SharedAccount_.issuer.contains(filter, caseSensitive: false)))
          ..order(SharedAccount_.position))
        .build()
        .find();
  }

  @override
  void deleteOld(List nextcloudAccountIds) {
    logger.d("SharedAccountRepositoryImpl._deleteOld start");

    super
        .box
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
    logger.d("SharedAccountRepositoryImpl._updateNeverSync start");

    super
        .box
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
    super
        .box
        .query(SharedAccount_.deleted.equals(false) &
            SharedAccount_.position.greaterThan(position))
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
    return super
        .box
        .query(SharedAccount_.deleted.equals(false) &
            SharedAccount_.position.greaterThan(min) &
            SharedAccount_.position.lessOrEqual(max))
        .build()
        .find();
  }

  @override
  SharedAccount? getByPosition(int position) {
    return super
        .box
        .query(SharedAccount_.position.equals(position))
        .build()
        .findFirst();
  }
}
