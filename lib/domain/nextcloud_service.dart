import 'dart:convert';

import 'package:otp_manager/domain/account_service.dart';
import 'package:otp_manager/main.dart';
import 'package:otp_manager/models/account.dart';
import 'package:otp_manager/repository/interface/account_repository.dart';
import 'package:otp_manager/repository/interface/shared_account_repository.dart';
import 'package:otp_manager/repository/interface/user_repository.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/utils/encryption.dart';
import 'package:otp_manager/utils/nextcloud_ocs_api.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../repository/interface/nextcloud_repository.dart';
import '../utils/base32.dart';

class NextcloudService {
  final NextcloudRepository nextcloudRepository;
  final UserRepository userRepository;
  final AccountRepository accountRepository;
  final AccountService accountService;
  final SharedAccountRepository sharedAccountRepository;
  final Encryption encryption;

  NextcloudService({
    required this.nextcloudRepository,
    required this.userRepository,
    required this.accountRepository,
    required this.accountService,
    required this.sharedAccountRepository,
    required this.encryption,
  });

  Future<Map<String, String?>> checkPassword(String password) async {
    logger.d("NextcloudService.checkPassword start");

    Map<String, String?> result = {"error": null, "iv": null};

    await nextcloudRepository.sendHttpRequest(
      resource: PasswordAPI.check,
      data: {"password": password},
      onComplete: (response) => result["iv"] = jsonDecode(response.body)["iv"],
      onFailed: (response) {
        if (response.statusCode == 404) {
          result["error"] =
              "You need to install the OTP Manager extension on your Nextcloud server to use this app.";
        } else {
          result["error"] = jsonDecode(response.body)["error"] ??
              "You need to set a password before. Please update the OTP Manager extension on your Nextcloud server to version 0.3.0 or higher.";
        }
      },
      onError: () => result["error"] =
          "An error encountered while checking password. Try to reload after a while!",
    );

    return result;
  }

  Future<Map<String, dynamic>> sync() async {
    logger.d("NextcloudService.sync start");

    Map<String, dynamic> syncResult = {
      "error": null,
      "accounts": {"toAdd": [], "toEdit": []},
      "sharedAccounts": {"toAdd": [], "toEdit": []},
    };

    final accounts = accountRepository.getAll();
    final sharedAccounts = sharedAccountRepository.getAll();
    final user = userRepository.get()!;

    if (user.password == null || user.iv == null) {
      NavigationService().replaceScreen(authRoute);
    }

    for (var e in accounts) {
      e.encryptedSecret ??= encryption.encrypt(data: e.secret);
      accountRepository.add(e); // update without sync
    }

    final appInfo = await PackageInfo.fromPlatform();

    var data = {
      "accounts": jsonDecode(accounts.toString()),
      "sharedAccounts": jsonDecode(sharedAccounts.toString()),
      "appVersion": appInfo.version
    };

    await nextcloudRepository.sendHttpRequest(
      resource: SyncAPI.sync,
      data: data,
      onComplete: (response) {
        var body = jsonDecode(response.body);

        if (body.isNotEmpty) {
          accountRepository.updateNeverSync();
          sharedAccountRepository.updateNeverSync();
          accountRepository.deleteOld(body["accounts"]["toDelete"]);
          sharedAccountRepository.deleteOld(body["sharedAccounts"]["toDelete"]);

          syncResult["accounts"] = body["accounts"];
          syncResult["sharedAccounts"] = body["sharedAccounts"];
        }
      },
      onFailed: (response) {
        if (response.statusCode == 404) {
          syncResult["error"] =
              "Please update the OTP Manager Nextcloud extension to version >= 0.5.0";
        } else {
          syncResult["error"] = jsonDecode(response.body)["error"] ??
              "The nextcloud server returns an error. Try to reload after a while!";
        }
      },
      onError: () => syncResult["error"] =
          "An error encountered while synchronising. Try to reload after a while!",
    );

    return syncResult;
  }

  bool _decryptSecretAccounts(List accounts) {
    final user = userRepository.get()!;

    for (var account in accounts) {
      account["encryptedSecret"] = account["secret"];

      if (account["unlocked"] == 0 || account["unlocked"] == false) continue;

      try {
        String decrypted = encryption.decrypt(dataBase64: account["secret"])!;

        if (!Base32.isValid(decrypted)) throw FormatException;

        account["secret"] = decrypted;
      } catch (_) {
        user.password = null;
        user.iv = null;
        userRepository.update(user);
        return false;
      }
    }

    return true;
  }

  bool syncAccountsToAddToEdit(
      Map<String, dynamic> accounts, Map<String, dynamic> sharedAccounts) {
    if (_decryptSecretAccounts(accounts["toAdd"]) &&
        _decryptSecretAccounts(accounts["toEdit"]) &&
        _decryptSecretAccounts(sharedAccounts["toAdd"]) &&
        _decryptSecretAccounts(sharedAccounts["toEdit"])) {
      accountRepository.addNew(accounts["toAdd"]);
      accountRepository.updateEdited(accounts["toEdit"]);
      sharedAccountRepository.addNew(sharedAccounts["toAdd"]);
      sharedAccountRepository.updateEdited(sharedAccounts["toEdit"]);

      return true;
    } else {
      return false;
    }
  }

  Future<String?> unlockSharedAccount(
      int accountId, String sharedPassword) async {
    final user = userRepository.get()!;

    String? result;

    await nextcloudRepository.sendHttpRequest(
      resource: "share/unlock",
      data: {
        "accountId": accountId,
        "currentPassword": user.password!,
        "tempPassword": sharedPassword,
      },
      onFailed: (response) => result = jsonDecode(response.body)["error"] ??
          "An error encountered while checking password. Try to reload after a while!",
      onError: () => result =
          "An error encountered while checking password. Try to reload after a while!",
    );

    return result;
  }

  Future<int?> updateCounter(dynamic account) async {
    int? result;

    await nextcloudRepository.sendHttpRequest(
      resource: account is Account
          ? AccountAPI.updateCounter
          : SharedAccountAPI.updateCounter,
      data: {"secret": account.encryptedSecret},
      onComplete: (response) => result = int.tryParse(response.body),
    );

    return result;
  }
}
