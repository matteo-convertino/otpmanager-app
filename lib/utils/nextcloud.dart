import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../main.dart' show objectBox, logger;
import '../models/account.dart';
import '../models/user.dart';
import '../object_box/objectbox.g.dart';
import '../utils/toast.dart';

class Nextcloud {
  Nextcloud({required this.user, this.callback});

  final Box<Account> _accountBox = objectBox.store.box<Account>();
  List<Account> _accounts = [];

  final User user;

  final Function? callback;

  int error = 0;

  void _returnError(String msg) {
    logger.d("Nextcloud._returnError start");

    showToast(msg);
    error = -1;
    callback!();
  }

  Future<http.Response> _sendHttpRequest(resource, data) {
    logger.d("Nextcloud._sendHttpRequest start");

    return http
        .post(Uri.parse("${user.url}/index.php/apps/otpmanager/$resource"),
            headers: {
              'Authorization': 'Bearer ${user.appPassword}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"data": data}))
        .timeout(const Duration(seconds: 5))
        .catchError((e, stackTrace) {
      logger.e(e);
      _returnError(
          "The nextcloud server is unreachable now. Try to reload after a while!");
      return http.Response('', 600);
    });
  }

  void _updateNeverSync() {
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

  void _addNewAccounts(List accounts) {
    logger.d("Nextcloud._addNewAccounts start");
    
    for (var account in accounts) {
      _accountBox.put(Account(
        name: account["name"],
        issuer: account["issuer"],
        secret: account["secret"],
        type: account["type"],
        dbAlgorithm: account["algorithm"],
        digits: account["digits"],
        period: account["period"],
        counter: account["counter"],
        position: account["position"],
        toUpdate: false,
        isNew: false,
      ));
    }
  }

  void _updateEditAccounts(List accounts) {
    logger.d("Nextcloud._updateEditAccounts start");

    for (var account in accounts) {
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
      accountToUpdate?.position = account["position"];
      _accountBox.put(accountToUpdate!);
    }
  }

  void _deleteOldAccounts(List accountIds) {
    logger.d("Nextcloud._deleteOldAccounts start");
    
    _accountBox
        .query(Account_.deleted.equals(true))
        .build()
        .find()
        .forEach((Account account) => _accountBox.remove(account.id));

    for (var id in accountIds) {
      _accountBox.remove(int.parse(id));
    }
  }

  void _adjustAccountsPosition(int start, int difference) {
    logger.d("Nextcloud._adjustAccountsPosition start");

    for (int i = start; i < _accounts.length; i++) {
      _accounts[i].position = _accounts[i].position! + difference;
      _accounts[i].toUpdate = true;
      _accountBox.put(_accounts[i]);
    }
  }

  void _checkPositions() {
    logger.d("Nextcloud._checkPositions start");

    bool repairedError = false;
    _accounts = _accountBox
        .query(Account_.deleted.equals(false))
        .order(Account_.position)
        .build()
        .find();

    // check if first account has position = 0
    if (_accounts.isNotEmpty) {
      if (_accounts[0].position != 0) {
        repairedError = true;
        _adjustAccountsPosition(0, -1);
      }

      // if there two accounts with same position
      // increment by 1 the position of all accounts after
      for (int i = 0; i < _accounts.length - 1; i++) {
        if (_accounts[i].position == _accounts[i + 1].position) {
          repairedError = true;
          _adjustAccountsPosition(i + 1, 1);
        }
      }

      if (repairedError) sync();
    }
  }

  void sync() async {
    logger.d("Nextcloud.sync start");

    if (user.isGuest == true) return;

    error = 1;
    callback!();

    _accounts = _accountBox.getAll();

    var data = {"accounts": jsonDecode(_accounts.toString())};
    print(jsonEncode({"data": data}));

    try {
      http.Response response = await _sendHttpRequest("accounts/sync", data);

      if (response.statusCode == 200) {
        _updateNeverSync();
        var body = jsonDecode(response.body);
        if (body.isNotEmpty) {
          _addNewAccounts(body["toAdd"]);
          _deleteOldAccounts(body["toDelete"]);
          _updateEditAccounts(body["toEdit"]);
        }

        _checkPositions();
        error = 0;
        callback!();
      } else if (response.statusCode != 600) {
        logger.e("statusCode: ${response.statusCode}\nbody: ${response.body}");
        _returnError(
            "The nextcloud server returns an error. Try to reload after a while!");
      }
    } catch (e) {
      logger.e(e);
    }
  }
}
