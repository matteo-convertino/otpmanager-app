import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  int id = 0;

  String url;
  String appPassword;

  bool copyWithTap = false;
  bool darkTheme = false;
  String? pin;

  bool isGuest;

  User({
    required this.url,
    required this.appPassword,
    required this.isGuest,
  });

  @override
  toString() => '{'
      'id: $id, '
      'url: $url, '
      'appPassword: $appPassword, '
      'copyWithTap: $copyWithTap, '
      'darkTheme: $darkTheme, '
      'isGuest: $isGuest'
      '}';
}
