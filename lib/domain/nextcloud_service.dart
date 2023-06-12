import 'dart:convert';

import 'package:otp_manager/main.dart';
import 'package:otp_manager/repository/local_repository.dart';

import '../repository/nextcloud_repository.dart';

import 'package:http/http.dart' as http;

class NextcloudService {
  final NextcloudRepositoryImpl _nextcloudRepositoryImpl;
  final LocalRepositoryImpl _localRepositoryImpl;

  NextcloudService(this._nextcloudRepositoryImpl, this._localRepositoryImpl);

  Future<String?> sync() async {
    logger.d("NextcloudService.sync start");

    final accounts = _localRepositoryImpl.getAllAccounts();

    var data = {"accounts": jsonDecode(accounts.toString())};

    try {
      final user = _localRepositoryImpl.getUser();
      http.Response response = await _nextcloudRepositoryImpl.sendHttpRequest(
          user, "accounts/sync", data);

      if (response.statusCode == 200) {
        _localRepositoryImpl.updateNeverSync();
        var body = jsonDecode(response.body);
        if (body.isNotEmpty) {
          _localRepositoryImpl.addNewAccounts(body["toAdd"]);
          _localRepositoryImpl.deleteOldAccounts(body["toDelete"]);
          _localRepositoryImpl.updateEditedAccounts(body["toEdit"]);
        }

        if (_localRepositoryImpl.repairPositionError()) sync();
      } else {
        logger.e("statusCode: ${response.statusCode}\nbody: ${response.body}");
        return "The nextcloud server returns an error. Try to reload after a while!";
      }
    } catch (e) {
      logger.e(e);
      return "An error encountered while synchronising. Try to reload after a while!";
    }

    return null;
  }
}
