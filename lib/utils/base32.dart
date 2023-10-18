import 'package:base32/base32.dart';

class Base32 {
  static bool isValid(String value) {
    try {
      base32.decode(value.toUpperCase());
      return true;
    } catch (e) {
      return false;
    }
  }
}
