import 'package:otp_manager/main.dart' show logger, objectBox;

import '../models/account.dart';
import '../models/user.dart';
import '../object_box/objectbox.g.dart';

abstract class LocalRepository {
  User? getUser();
  void addUser(User user);
  void updateUser(User user);
  void addAccount(Account account);
  bool accountAlreadyExists(String secret);
  bool isLogged();
  List<Account> getAllAccounts();
  void updateEditedAccounts(List nextcloudAccounts);
  void deleteOldAccounts(List nextcloudAccountIds);
  void addNewAccounts(List nextcloudAccounts);
  void updateNeverSync();
  bool repairPositionError();
  List<Account> getVisibleAccounts();
  List<Account> getVisibleFilteredAccounts(String filter);
  void removeAllUsers();
  void removeAllAccounts();
  void removeAccount(int id);
  void updateAccount(Account account);
  Account? getAccount(int id);
  Account? getAccountBySecret(String secret);
  void scaleAccountsPositionAfter(int position);
  List<Account> getAccountBetweenPositions(int min, int max);
  Account? getAccountByPosition(int position);
  bool setAccountAsDeleted(int id);
  int? getAccountLastPosition();
}

class LocalRepositoryImpl extends LocalRepository {
  final _userBox = objectBox.store.box<User>();
  final _accountBox = objectBox.store.box<Account>();

  @override
  User? getUser() {
    final users = _userBox.getAll();

    return users.isNotEmpty ? users[0] : null;
  }

  @override
  void addUser(User user) {
    _userBox.put(user);
  }

  @override
  void updateUser(User user) {
    _userBox.put(user);
  }

  @override
  void addAccount(Account account) {
    _accountBox.put(account);
  }

  @override
  bool accountAlreadyExists(String secret) {
    return _accountBox
        .query(Account_.secret.equals(secret))
        .build()
        .find()
        .isNotEmpty;
  }

  @override
  bool isLogged() {
    return _userBox.getAll().isNotEmpty;
  }

  @override
  List<Account> getAllAccounts() {
    return _accountBox.getAll();
  }

  @override
  void updateEditedAccounts(List nextcloudAccounts) {
    logger.d("Nextcloud._updateEditedAccounts start");

    for (var account in nextcloudAccounts) {
      Account? accountToUpdate = _accountBox
          .query(Account_.secret.equals(account["secret"]))
          .build()
          .findFirst();
      accountToUpdate?.name = account["name"];
      accountToUpdate?.issuer = account["issuer"];
      accountToUpdate?.digits = account["digits"];
      accountToUpdate?.type = account["type"];
      accountToUpdate?.dbAlgorithm = account["algorithm"];
      accountToUpdate?.period = account["period"];
      accountToUpdate?.counter = account["counter"];
      accountToUpdate?.iconKey = account["icon"] ?? accountToUpdate.iconKey;
      accountToUpdate?.position = account["position"];
      _accountBox.put(accountToUpdate!);
    }
  }

  @override
  void deleteOldAccounts(List nextcloudAccountIds) {
    logger.d("Nextcloud._deleteOldAccounts start");

    _accountBox
        .query(Account_.deleted.equals(true))
        .build()
        .find()
        .forEach((Account account) => _accountBox.remove(account.id));

    for (var id in nextcloudAccountIds) {
      _accountBox.remove(int.parse(id));
    }
  }

  @override
  bool repairPositionError() {
    logger.d("Nextcloud._checkPositions start");

    final accounts = _accountBox
        .query(Account_.deleted.equals(false))
        .order(Account_.position)
        .build()
        .find();

    void adjustAccountsPosition(int start, int difference) {
      logger.d("Nextcloud._adjustAccountsPosition start");

      for (int i = start; i < accounts.length; i++) {
        accounts[i].position = accounts[i].position! + difference;
        accounts[i].toUpdate = true;
        _accountBox.put(accounts[i]);
      }
    }

    bool repairedError = false;

    // check if first account has position = 0
    if (accounts.isNotEmpty) {
      if (accounts[0].position != 0) {
        repairedError = true;
        adjustAccountsPosition(0, -1);
      }

      // if there two accounts with same position
      // increment by 1 the position of all accounts after
      for (int i = 0; i < accounts.length - 1; i++) {
        if (accounts[i].position == accounts[i + 1].position) {
          repairedError = true;
          adjustAccountsPosition(i + 1, 1);
        }
      }

      return repairedError;
    }

    return false;
  }

  @override
  void updateNeverSync() {
    logger.d("Nextcloud._updateNeverSync start");

    _accountBox
        .query(Account_.toUpdate.equals(true) | Account_.isNew.equals(true))
        .build()
        .find()
        .forEach((Account account) {
      account.isNew = false;
      account.toUpdate = false;
      _accountBox.put(account);
    });
  }

  @override
  void addNewAccounts(List nextcloudAccounts) {
    logger.d("Nextcloud._addNewAccounts start");

    for (var account in nextcloudAccounts) {
      _accountBox.put(
        Account(
          name: account["name"],
          issuer: account["issuer"],
          secret: account["secret"],
          encryptedSecret: account["encryptedSecret"],
          type: account["type"],
          dbAlgorithm: account["algorithm"],
          digits: account["digits"],
          period: account["period"],
          counter: account["counter"],
          icon: account["icon"],
          position: account["position"],
          toUpdate: false,
          isNew: false,
        ),
      );
    }
  }

  @override
  List<Account> getVisibleAccounts() {
    return (_accountBox.query(Account_.deleted.equals(false))
          ..order(Account_.position))
        .build()
        .find();
  }

  @override
  List<Account> getVisibleFilteredAccounts(String filter) {
    return (_accountBox.query(Account_.deleted.equals(false) &
            (Account_.name.contains(filter, caseSensitive: false) |
                Account_.issuer.contains(filter, caseSensitive: false)))
          ..order(Account_.position))
        .build()
        .find();
  }

  @override
  void removeAllAccounts() {
    _accountBox.removeAll();
  }

  @override
  void removeAllUsers() {
    _userBox.removeAll();
  }

  @override
  void removeAccount(int id) {
    _accountBox.remove(id);
  }

  @override
  void updateAccount(Account account) {
    _accountBox.put(account);
  }

  @override
  Account? getAccount(int id) {
    return _accountBox.get(id);
  }

  @override
  Account? getAccountBySecret(String secret) {
    return _accountBox
        .query(Account_.secret.equals(secret))
        .build()
        .findFirst();
  }

  @override
  void scaleAccountsPositionAfter(int position) {
    _accountBox
        .query(Account_.deleted.equals(false) &
            Account_.position.greaterThan(position))
        .build()
        .find()
        .forEach((account) {
      account.position = account.position! - 1;
      account.toUpdate = true;
      _accountBox.put(account);
    });
  }

  @override
  List<Account> getAccountBetweenPositions(int min, int max) {
    return _accountBox
        .query(Account_.deleted.equals(false) &
            Account_.position.greaterThan(min) &
            Account_.position.lessOrEqual(max))
        .build()
        .find();
  }

  @override
  Account? getAccountByPosition(int position) {
    return _accountBox
        .query(Account_.position.equals(position))
        .build()
        .findFirst();
  }

  @override
  bool setAccountAsDeleted(int id) {
    Account? accountToRemove = getAccount(id);

    if (accountToRemove != null) {
      accountToRemove.deleted = true;

      scaleAccountsPositionAfter(accountToRemove.position!);

      accountToRemove.position = null;
      updateAccount(accountToRemove);
      return true;
    }

    return false;
  }

  @override
  int? getAccountLastPosition() {
    return (_accountBox.query(Account_.deleted.equals(false))
          ..order(Account_.position, flags: Order.descending))
        .build()
        .findFirst()
        ?.position;
  }
}
