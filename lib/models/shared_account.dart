import 'package:objectbox/objectbox.dart';
import 'package:otp/otp.dart';

@Entity()
class SharedAccount {
  int id = 0;

  @Unique()
  String? secret;
  @Unique()
  String encryptedSecret;

  // Customizable fields
  String name;
  String? issuer;
  int? position;
  String iconKey = 'default';

  // Required fields to generate code
  @Property(uid: 541832795838973838)
  int period;
  @Property(uid: 8305642788148493574)
  int digits;
  String type;

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

  int? counter;

  String password;
  String iv;
  bool unlocked;

  DateTime? expiredAt;

  String sharerUserId;

  // Synchronization
  bool deleted = false;
  bool toUpdate = false;
  int nextcloudAccountId; // the account_id stored on nextcloud server

  SharedAccount({
    this.secret,
    required this.encryptedSecret,
    required this.name,
    this.issuer,
    this.position,
    required this.period,
    required this.digits,
    required this.type,
    required this.unlocked,
    required this.password,
    required this.iv,
    this.toUpdate = false,
    required this.nextcloudAccountId,
    required this.sharerUserId,
    this.expiredAt,
    int? dbAlgorithm,
    int? counter,
    this.iconKey = 'default',
  }) {
    if (type == 'hotp') {
      this.counter = counter ?? -1;
    }

    this.dbAlgorithm = dbAlgorithm;
  }

  String toUri() {
    return Uri.encodeFull(
      'otpauth://'
      '$type/'
      '$name?'
      'secret=$secret&'
      'issuer=$issuer&'
      'period=$period&'
      'digits=$digits&'
      'algorithm=${algorithm.name.toUpperCase()}'
      "${type == "hotp" ? '&counter=$counter' : ''}",
    );
  }

  void _ensureStableEnumValues() {
    assert(Algorithm.SHA1.index == 0);
    assert(Algorithm.SHA256.index == 1);
    assert(Algorithm.SHA512.index == 2);
  }

  @override
  toString() =>
      '{'
      '"id": $id, '
      '"secret": "$encryptedSecret", '
      '"name": "$name", '
      '"issuer": "$issuer", '
      '"position": $position, '
      '"unlocked": $unlocked, '
      '"icon": "$iconKey", '
      '"deleted": $deleted, '
      '"toUpdate": $toUpdate, '
      '"accountId": $nextcloudAccountId, '
      '"expiredAt": "$expiredAt"'
      '}';
}
