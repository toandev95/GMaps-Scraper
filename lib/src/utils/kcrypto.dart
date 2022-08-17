import 'package:encrypt/encrypt.dart';

class Kcrypto {
  static final Key key = Key.fromUtf8('NcRfUjXn2r4u7x!A%D*G-KaPdSgVkY11');
  static final IV iv = IV.fromLength(16);

  static String encrypt(String input) {
    final Encrypter encrypter = Encrypter(AES(key));
    final Encrypted encrypted = encrypter.encrypt(
      input,
      iv: iv,
    );

    return '${encrypted.base64}++';
  }

  static String decrypt(String input) {
    final Encrypter encrypter = Encrypter(AES(key));
    final Encrypted encrypted = Encrypted.fromBase64(
      input.substring(0, input.length - 2),
    );

    print(encrypted);

    return encrypter.decrypt(
      encrypted,
      iv: iv,
    );
  }
}
