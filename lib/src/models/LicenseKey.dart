import 'package:gmaps_scraper_app/src/exceptions/LicenseKeyException.dart';

enum LicenseKeyType {
  TRIAL,
  PREMIUM,
}

class LicenseKey {
  String? fullName;
  String? email;
  String? deviceId;
  DateTime? expiryDate;
  LicenseKeyType? type;

  LicenseKey({
    this.fullName,
    this.email,
    this.deviceId,
    this.expiryDate,
    this.type,
  });

  static LicenseKey fromString(String val) {
    final List<String> ls = val.split('|');

    if (ls.length != 5) {
      throw LicenseKeyException();
    }

    return LicenseKey(
      deviceId: ls[0],
      fullName: ls[1],
      email: ls[2],
      expiryDate: DateTime.tryParse(ls[3])?.toLocal(),
      type: ls[4] == 'premium' ? LicenseKeyType.PREMIUM : LicenseKeyType.TRIAL,
    );
  }
}
