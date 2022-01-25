import 'package:google_maps_scraper_app/src/exceptions/exceptions.dart';
import 'package:google_maps_scraper_app/src/utils/utils.dart';

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
    final List<String> _ls = Kcrypto.decrypt(val).split('*');

    if (_ls.length != 5) {
      throw LicenseKeyException();
    }

    return LicenseKey(
      productName: _ls[0],
      deviceId: _ls[1],
      expiresAt: DateTime.parse(_ls[2]),
      name: _ls[3],
      email: _ls[4],
      raw: val,
    );
  }
}
