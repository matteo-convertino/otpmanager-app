import 'package:encrypter_plus/encrypter_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:otp_manager/repository/local/interface/user_repository.dart';

@LazySingleton()
class EncryptionService {
  final UserRepository userRepository;

  EncryptionService({required this.userRepository});

  String? decrypt({
    required String dataBase64,
    String? keyBase16,
    String? ivBase16,
  }) {
    if (keyBase16 == null || ivBase16 == null) {
      final user = userRepository.get();
      if (user == null || user.password == null || user.iv == null) return null;

      keyBase16 = user.password!;
      ivBase16 = user.iv!;
    }

    final encrypter = _getEncrypter(keyBase16);

    return encrypter.decrypt(
      Encrypted.from64(dataBase64),
      iv: IV.fromBase16(ivBase16),
    );
  }

  String? encrypt({required String data, String? keyBase16, String? ivBase16}) {
    if (keyBase16 == null || ivBase16 == null) {
      final user = userRepository.get();
      if (user == null || user.password == null || user.iv == null) return null;

      keyBase16 = user.password!;
      ivBase16 = user.iv!;
    }

    final encrypter = _getEncrypter(keyBase16);

    return encrypter.encrypt(data, iv: IV.fromBase16(ivBase16)).base64;
  }

  Encrypter _getEncrypter(String keyBase16) {
    return Encrypter(AES(Key.fromBase16(keyBase16), mode: AESMode.cbc));
  }
}
