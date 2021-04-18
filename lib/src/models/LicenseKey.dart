import 'package:gmaps_scraper_app/src/exceptions/LicenseKeyException.dart';

class LicenseKey {
  final String? fullName;
  final String? email;
  final String? deviceId;
  final DateTime? expiryDate;

  LicenseKey({
    this.fullName,
    this.email,
    this.deviceId,
    this.expiryDate,
  });

  static LicenseKey fromString(String val) {
    final List<String> ls = val.split('|');

    if (ls.length != 4) {
      throw LicenseKeyException();
    }

    return LicenseKey(
      fullName: ls[0],
      email: ls[1],
      deviceId: ls[2],
      expiryDate: DateTime.tryParse(ls[3])?.toLocal(),
    );
  }
}
