import 'package:objectbox/objectbox.dart';
import 'package:otp/otp.dart';

import '../utils/simple_icons.dart';

enum AlgorithmTypes { sha1, sha256, sha512 }

@Entity()
class Account {
  int id = 0;

  @Unique()
  String secret;
  @Unique()
  String? encryptedSecret;

  String name;
  String? issuer;
  int? digits;
  String type;
  int? period;

  // HOTP code
  int? counter;

  // Synchronization
  bool deleted = false;
  bool toUpdate = false;
  bool isNew = true;

  int? position;

  String iconKey = 'default';

  @Transient()
  late Algorithm algorithm;

  int? get dbAlgorithm {
    _ensureStableEnumValues();
    return algorithm.index;
  }

  set dbAlgorithm(int? value) {
    _ensureStableEnumValues();
    if (value == 1) {
      algorithm = Algorithm.SHA256;
    } else if (value == 2) {
      algorithm = Algorithm.SHA512;
    } else {
      algorithm = Algorithm.SHA1;
    }
  }

  Account({
    required this.secret,
    this.encryptedSecret,
    required this.name,
    this.issuer,
    this.digits,
    required this.type,
    this.period,
    this.position,
    this.toUpdate = false,
    this.isNew = true,
    int? counter,
    int? dbAlgorithm,
    String? icon,
  }) {
    if (type == "hotp") {
      this.counter = counter ?? 0;
    }

    this.dbAlgorithm = dbAlgorithm;

    // set default value
    digits = digits ?? 6;
    period = period ?? 30;

    if(icon != null && icon != "default") {
      iconKey = icon;
    } else if(issuer != null && issuer != "") {
      String toFind = issuer!.replaceAll(" ", "").toLowerCase();
      iconKey = simpleIcons.keys.firstWhere((v) => v.contains(toFind), orElse: () => "default");
    } else {
      iconKey = "default";
    }
  }

  void _ensureStableEnumValues() {
    assert(AlgorithmTypes.sha1.index == 0);
    assert(AlgorithmTypes.sha256.index == 1);
    assert(AlgorithmTypes.sha512.index == 2);
  }

  String toUri() {
    return Uri.encodeFull("otpauth://"
        "$type/"
        "$name?"
        "secret=$secret&"
        "issuer=$issuer&"
        "period=$period&"
        "digits=$digits&"
        "algorithm=${algorithm.name.toUpperCase()}"
        "${type == "hotp" ? '&counter=$counter' : ''}");
  }

  @override
  toString() => '{'
      '"id": "$id", '
      '"secret": "$encryptedSecret", '
      '"name": "$name", '
      '"issuer": "$issuer", '
      '"algorithm": "$dbAlgorithm", '
      '"digits": $digits, '
      '"type": "$type", '
      '"period": $period, '
      '"counter": $counter, '
      '"position": $position, '
      '"icon": "$iconKey", '
      '"deleted": $deleted, '
      '"toUpdate": $toUpdate, '
      '"isNew": $isNew'
      '}';
}
