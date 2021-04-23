import 'package:gmaps_scraper_app/src/Models/Models.dart';

class Province {
  int? id;
  String? name;
  List<District>? districts;

  Province({
    this.id,
    this.name,
    this.districts,
  });

  static Province fromMap(Map<String, Object?> json) {
    return Province(
      id: (json['id'] as int),
      name: (json['name'] as String),
      districts: <District>[],
    );
  }
}
