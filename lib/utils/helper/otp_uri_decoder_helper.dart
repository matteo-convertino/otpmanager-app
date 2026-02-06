import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:diacritic/diacritic.dart';
import 'package:otp/otp.dart';

import '../../../generated_protoc/google_auth.pb.dart';
import '../../models/account.dart';

class OtpUriDecoderHelper {
  static bool isValid(String uri) {
    return uri.contains('otpauth');
  }

  static int getAlgorithmIndexFromString(String algorithm) => Algorithm.values
      .firstWhere((e) => e.name == algorithm, orElse: () => Algorithm.SHA1)
      .index;

  static List<Account> decodeOtpUri(String uri) {
    var uriDecoded = Uri.parse(uri);

    if (_isGoogle(uri)) return _decodeGoogleUri(uriDecoded);

    List<Account> accounts = [];

    var tmp = uriDecoded.queryParameters;
    var nameAndIssuer = _getNameAndIssuer(uriDecoded);

    var newAccount = Account(
      secret: tmp['secret'].toString().toUpperCase(),
      name: removeDiacritics(Uri.decodeFull(nameAndIssuer['name'])),
      issuer: removeDiacritics(Uri.decodeFull(nameAndIssuer['issuer'] ?? '')),
      dbAlgorithm: getAlgorithmIndexFromString(tmp['algorithm'].toString()),
      digits: int.tryParse(tmp['digits'].toString()),
      type: uriDecoded.host,
      period: int.tryParse(tmp['period'].toString()),
    );

    accounts.add(newAccount);

    return accounts;
  }

  static List<Account> _decodeGoogleUri(Uri uri) {
    String? data = uri.queryParameters['data'];
    Uint8List decoded = base64.decode(data!);

    var payload = MigrationPayload.fromBuffer(decoded);

    List<Account> accounts = [];

    payload.otpParameters.asMap().forEach((index, params) {
      var tmp = params.toProto3Json() as Map;
      tmp['name'] = Uri.decodeFull(removeDiacritics(tmp['name'].toString()));
      String secret = base32
          .encode(Uint8List.fromList(payload.otpParameters[index].secret))
          .toUpperCase();

      var newAccount = Account(
        secret: secret,
        name: tmp['name'].contains(':')
            ? tmp['name'].split(':')[1]
            : tmp['name'],
        issuer: Uri.decodeFull(removeDiacritics(tmp['issuer'] ?? '')),
        dbAlgorithm: getAlgorithmIndexFromString(tmp['algorithm']),
        digits: 6,
        type: tmp['type'],
        period: 30,
      );

      accounts.add(newAccount);
    });

    return accounts;
  }

  static bool _isGoogle(String uri) {
    return uri.contains('otpauth-migration://offline?data=');
  }

  static Map _getNameAndIssuer(Uri queryUriParams) {
    Map params = {};

    var query = queryUriParams.queryParameters;
    var path = queryUriParams.path;

    if (path.contains(':')) {
      var tmp = path.split(':');
      params['issuer'] = tmp[0].replaceAll('/', '');
      params['name'] = tmp[1];
    } else if (path.contains('@')) {
      var tmp = path.split('@');
      params['name'] = tmp[0].replaceAll('/', '');
      params['issuer'] = tmp[1];
    } else if (query['issuer'] != null) {
      params['name'] = path.replaceAll('/', '');
      params['issuer'] = query['issuer'];
    } else {
      params['name'] = path.replaceAll('/', '');
    }

    return params;
  }
}
