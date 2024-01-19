import 'package:objectbox/objectbox.dart';
import 'package:otp/otp.dart';

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
    this.iconKey = 'default',
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
  }) {
    if (type == "hotp") {
      this.counter = counter ?? 0;
    }

    this.dbAlgorithm = dbAlgorithm;

    // set default value
    digits = digits ?? 6;
    period = period ?? 30;
  }

  void _ensureStableEnumValues() {
    assert(AlgorithmTypes.sha1.index == 0);
    assert(AlgorithmTypes.sha256.index == 1);
    assert(AlgorithmTypes.sha512.index == 2);
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
      '"deleted": $deleted, '
      '"toUpdate": $toUpdate, '
      '"isNew": $isNew'
      '}';
}
