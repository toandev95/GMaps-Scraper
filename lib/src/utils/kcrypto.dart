import 'package:encrypt/encrypt.dart';

class Kcrypto {
  static final Key key = Key.fromUtf8('NcRfUjXn2r4u7x!A%D*G-KaPdSgVkY11');
  static final IV iv = IV.fromLength(16);

  static String encrypt(String input) {
    final Encrypter _encrypter = Encrypter(AES(key));
    final Encrypted _encrypted = _encrypter.encrypt(
      input,
      iv: iv,
    );

    return '${_encrypted.base64}++';
  }

  static String decrypt(String input) {
    final Encrypter _encrypter = Encrypter(AES(key));
    final Encrypted _encrypted = Encrypted.fromBase64(
      input.substring(0, input.length - 2),
    );

    return _encrypter.decrypt(
      _encrypted,
      iv: iv,
    );
  }
}
