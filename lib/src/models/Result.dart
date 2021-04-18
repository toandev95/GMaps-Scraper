import 'package:intl/intl.dart';

class Result {
  int? keywordId;
  int? cityId;
  String? url;
  String? imageUrl;
  String? title;
  int? categoryId;
  double? star;
  int? review;
  List<int>? editorialIds;
  String? address;
  String? phone;
  String? hour;
  DateTime? createdAt;

  Result({
    this.cityId,
    this.url,
    this.imageUrl,
    this.title,
    this.categoryId,
    this.star,
    this.review,
    this.editorialIds,
    this.address,
    this.phone,
    this.hour,
    this.createdAt,
  });

  Map<String, String> toMapSQL() {
    return {
      'keyword_id': keywordId,
      'city_id': cityId,
      'url': url,
      'image_url': imageUrl,
      'title': title,
      'category_id': categoryId,
      'star': star,
      'review': review,
      'address': address,
      'phone': phone,
      'hour': hour,
      'created_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt!),
    }.map(
      (key, value) => MapEntry(
        key,
        value != null ? '$value' : 'NULL',
      ),
    );
  }
}
