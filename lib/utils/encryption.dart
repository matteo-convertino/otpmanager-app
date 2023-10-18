import 'package:encrypt/encrypt.dart';

class Encryption {
  static String decrypt(String dataBase64, String keyBase16, String ivBase16) {
    final encrypter = _getEncrypter(keyBase16);

    return encrypter.decrypt(
      Encrypted.from64(dataBase64),
      iv: IV.fromBase16(ivBase16),
    );
  }

  static String encrypt(String data, String keyBase16, String ivBase16) {
    final encrypter = _getEncrypter(keyBase16);

    return encrypter.encrypt(data, iv: IV.fromBase16(ivBase16)).base64;
  }

  static Encrypter _getEncrypter(String keyBase16) {
    return Encrypter(AES(Key.fromBase16(keyBase16), mode: AESMode.cbc));
  }
}
