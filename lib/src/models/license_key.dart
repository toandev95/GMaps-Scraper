import 'package:gmaps_scraper_app/src/exceptions/exceptions.dart';
import 'package:gmaps_scraper_app/src/utils/utils.dart';

class LicenseKey {
  final String productName;
  final String deviceId;
  final DateTime expiresAt;
  final String name;
  final String email;
  final String raw;

  LicenseKey({
    required this.productName,
    required this.deviceId,
    required this.expiresAt,
    required this.name,
    required this.email,
    required this.raw,
  });

  static LicenseKey fromKey(String val) {
    final List<String> ls = Kcrypto.decrypt(val).split('*');

    if (ls.length != 5) {
      throw LicenseKeyException();
    }

    return LicenseKey(
      productName: ls[0],
      deviceId: ls[1],
      expiresAt: DateTime.parse(ls[2]),
      name: ls[3],
      email: ls[4],
      raw: val,
    );
  }
}
