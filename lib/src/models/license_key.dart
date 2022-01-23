import 'package:google_maps_scraper_app/src/exceptions/exceptions.dart';

class LicenseKey {
  final String deviceId;
  final DateTime expiresAt;
  final String name;
  final String email;

  LicenseKey({
    required this.deviceId,
    required this.expiresAt,
    required this.name,
    required this.email,
  });

  static LicenseKey fromKey(String val) {
    final List<String> _ls = val.split('*');

    if (_ls.length != 4) {
      throw LicenseKeyException();
    }

    return LicenseKey(
      deviceId: _ls[0],
      expiresAt: DateTime.parse(_ls[1]),
      name: _ls[2],
      email: _ls[3],
    );
  }
}
