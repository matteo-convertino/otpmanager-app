import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:otp_manager/main.dart';
import 'package:otp_manager/repository/local_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/utils/encryption.dart';

import '../repository/nextcloud_repository.dart';
import '../utils/base32.dart';

class NextcloudService {
  final NextcloudRepositoryImpl _nextcloudRepositoryImpl;
  final LocalRepositoryImpl _localRepositoryImpl;

  NextcloudService(this._nextcloudRepositoryImpl, this._localRepositoryImpl);

  Future<Map<String, String?>> checkPassword(String password) async {
    logger.d("NextcloudService.checkPassword start");

    Map<String, String?> result = {"error": null, "iv": null};

    try {
      http.Response response = await _nextcloudRepositoryImpl.sendHttpRequest(
        _localRepositoryImpl.getUser()!,
        "password/check",
        jsonEncode({"password": password}),
      );

      if (response.statusCode == 400) {
        var body = jsonDecode(response.body);
        logger.e("statusCode: ${response.statusCode}\nbody: ${response.body}");
        result["error"] = body["error"];
      } else if (response.statusCode == 404) {
        result["error"] =
            "You need to set a password before. Please update the OTP Manager extension on your Nextcloud server to version 0.3.0 or higher.";
      } else {
        var body = jsonDecode(response.body);
        result["iv"] = body["iv"];
      }
    } catch (e) {
      logger.e(e);
      result["error"] =
          "An error encountered while checking password. Try to reload after a while!";
    }

    return result;
  }

  Future<Map<String, dynamic>> sync() async {
    logger.d("NextcloudService.sync start");

    Map<String, dynamic> syncResult = {
      "error": null,
      "toAdd": [],
      "toEdit": []
    };

    final accounts = _localRepositoryImpl.getAllAccounts();
    final user = _localRepositoryImpl.getUser()!;

    if (user.password == null || user.iv == null) {
      NavigationService().replaceScreen(authRoute);
    }

    for (var e in accounts) {
      e.encryptedSecret ??=
          Encryption.encrypt(e.secret, user.password!, user.iv!);
    }

    var data = jsonEncode({"accounts": jsonDecode(accounts.toString())});

    try {
      final user = _localRepositoryImpl.getUser();
      http.Response response = await _nextcloudRepositoryImpl.sendHttpRequest(
        user,
        "accounts/sync",
        data,
      );

      if (response.statusCode == 200) {
        _localRepositoryImpl.updateNeverSync();
        var body = jsonDecode(response.body);
        if (body.isNotEmpty) {
          _localRepositoryImpl.deleteOldAccounts(body["toDelete"]);
          syncResult["toAdd"] = body["toAdd"];
          syncResult["toEdit"] = body["toEdit"];
        }

        if (_localRepositoryImpl.repairPositionError()) sync();
      } else {
        logger.e("statusCode: ${response.statusCode}\nbody: ${response.body}");
        syncResult["error"] =
            "The nextcloud server returns an error. Try to reload after a while!";
      }
    } catch (e) {
      logger.e(e);
      syncResult["error"] =
          "An error encountered while synchronising. Try to reload after a while!";
    }

    return syncResult;
  }

  bool _decryptSecretAccounts(List accounts) {
    final user = _localRepositoryImpl.getUser()!;

    for (var account in accounts) {
      account["encryptedSecret"] = account["secret"];

      try {
        var decrypted =
            Encryption.decrypt(account["secret"], user.password!, user.iv!);

        if (!Base32.isValid(decrypted)) throw FormatException;

        account["secret"] = decrypted;
      } catch (_) {
        user.password = null;
        user.iv = null;
        _localRepositoryImpl.updateUser(user);
        return false;
      }
    }

    return true;
  }
  
  bool syncAccountsToAddToEdit(List accountsToAdd, List accountsToEdit) {
    if (_decryptSecretAccounts(accountsToAdd) &&
        _decryptSecretAccounts(accountsToEdit)) {
      _localRepositoryImpl.addNewAccounts(accountsToAdd);
      _localRepositoryImpl.updateEditedAccounts(accountsToEdit);
      return true;
    } else {
      return false;
    }
  }
}
