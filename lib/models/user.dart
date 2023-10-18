import 'package:objectbox/objectbox.dart';

enum PasswordAskTime { everySync, oneMinutes, threeMinutes, fiveMinutes, never }

@Entity()
class User {
  int id = 0;

  String url;
  String appPassword;

  bool copyWithTap = false;
  bool darkTheme = false;

  @Property(uid: 6627109253779031772)
  String? password;

  String? iv;

  bool isGuest;

  @Transient()
  late PasswordAskTime passwordAskTime;
  DateTime? passwordExpirationDate = DateTime.now();

  int? get dbPasswordAskTime {
    _ensureStableEnumValues();
    return passwordAskTime.index;
  }

  set dbPasswordAskTime(int? value) {
    _ensureStableEnumValues();
    if (value == 0) {
      passwordAskTime = PasswordAskTime.everySync;
    } else if (value == 1) {
      passwordAskTime = PasswordAskTime.oneMinutes;
    } else if (value == 2) {
      passwordAskTime = PasswordAskTime.threeMinutes;
    } else if (value == 3) {
      passwordAskTime = PasswordAskTime.fiveMinutes;
    } else {
      passwordAskTime = PasswordAskTime.never;
    }
  }

  User({
    required this.url,
    required this.appPassword,
    required this.isGuest,
  }) {
    dbPasswordAskTime = 0;
  }

  void _ensureStableEnumValues() {
    assert(PasswordAskTime.everySync.index == 0);
    assert(PasswordAskTime.oneMinutes.index == 1);
    assert(PasswordAskTime.threeMinutes.index == 2);
    assert(PasswordAskTime.fiveMinutes.index == 3);
    assert(PasswordAskTime.never.index == 4);
  }

  @override
  toString() => '{'
      'id: $id, '
      'url: $url, '
      'appPassword: $appPassword, '
      'copyWithTap: $copyWithTap, '
      'darkTheme: $darkTheme, '
      'passwordAskTime: $passwordAskTime, '
      'passwordExpirationDate: $passwordExpirationDate, '
      'isGuest: $isGuest'
      '}';
}
