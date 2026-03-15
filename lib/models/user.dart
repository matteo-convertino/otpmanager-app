import 'package:objectbox/objectbox.dart';
import 'package:otp_manager/utils/enum/password_ask_time.dart';
import 'package:otp_manager/utils/enum/theme_mode.dart';

@Entity()
class User {
  int id = 0;

  String url;
  String appPassword;

  bool copyWithTap = false;
  bool openSearchBarOnStartup = false;
  bool clickToRevealCodes = false;
  bool blackTheme = false;

  @Transient()
  late ThemeMode themeMode;

  // null = not selected, true = ascending, false = descending
  bool? sortedByNameDesc;
  bool? sortedByIssuerDesc;
  bool? sortedByIdDesc;

  @Property(uid: 6627109253779031772)
  String? password;

  String? iv;

  bool isGuest;

  @Transient()
  late PasswordAskTime passwordAskTime;
  DateTime? passwordExpirationDate = DateTime.now();

  int? get dbPasswordAskTime {
    _ensurePasswordAskTimeEnumValues();
    return passwordAskTime.index;
  }

  set dbPasswordAskTime(int? value) {
    _ensurePasswordAskTimeEnumValues();
    passwordAskTime = switch (value) {
      0 => PasswordAskTime.everyOpening,
      1 => PasswordAskTime.oneMinute,
      2 => PasswordAskTime.threeMinutes,
      3 => PasswordAskTime.fiveMinutes,
      _ => PasswordAskTime.never,
    };
  }

  int? get dbThemeMode {
    _ensureThemeModeEnumValues();
    return themeMode.index;
  }

  set dbThemeMode(int? value) {
    _ensureThemeModeEnumValues();
    themeMode = switch (value) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  User({required this.url, required this.appPassword, required this.isGuest}) {
    dbPasswordAskTime = 0;
    dbThemeMode = 2;
  }

  void _ensurePasswordAskTimeEnumValues() {
    assert(PasswordAskTime.everyOpening.index == 0);
    assert(PasswordAskTime.oneMinute.index == 1);
    assert(PasswordAskTime.threeMinutes.index == 2);
    assert(PasswordAskTime.fiveMinutes.index == 3);
    assert(PasswordAskTime.never.index == 4);
  }

  void _ensureThemeModeEnumValues() {
    assert(ThemeMode.light.index == 0);
    assert(ThemeMode.dark.index == 1);
    assert(ThemeMode.system.index == 2);
  }

  void updatePasswordExpirationDate() {
    final now = DateTime.now();

    passwordExpirationDate = switch (passwordAskTime) {
      PasswordAskTime.never => null,
      PasswordAskTime.everyOpening => now,
      PasswordAskTime.oneMinute => now.add(const Duration(minutes: 1)),
      PasswordAskTime.threeMinutes => now.add(const Duration(minutes: 3)),
      PasswordAskTime.fiveMinutes => now.add(const Duration(minutes: 5)),
    };
  }

  @override
  toString() =>
      '{'
      'id: $id, '
      'url: "$url", '
      'appPassword: "$appPassword", '
      'copyWithTap: $copyWithTap, '
      'themeMode: $themeMode, '
      'openSearchBarOnStartup: $openSearchBarOnStartup, '
      'clickToRevealCodes: $clickToRevealCodes, '
      'blackTheme: $blackTheme, '
      'passwordAskTime: $passwordAskTime, '
      'passwordExpirationDate: $passwordExpirationDate, '
      'isGuest: $isGuest'
      '}';
}
