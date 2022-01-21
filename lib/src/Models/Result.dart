import 'package:sqlite3/sqlite3.dart';

class Result {
  int? id;
  String? key;
  String? label;
  String keyword;
  String? title;
  String? subTitle;
  double? star;
  int? totalReview;
  String? categoryName;
  List<String>? attributes;
  String? address;
  String? openHours;
  String? websiteUrl;
  String? phoneNumber;
  String? imageUrl;
  DateTime? createdAt;

  Result({
    this.id,
    this.key,
    this.label,
    required this.keyword,
    this.title,
    this.subTitle,
    this.star,
    this.totalReview,
    this.categoryName,
    this.attributes,
    this.address,
    this.openHours,
    this.websiteUrl,
    this.phoneNumber,
    this.imageUrl,
    this.createdAt,
  });

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'label': label,
      'keyword': keyword,
      'title': title,
      'sub_title': subTitle,
      'star': star,
      'total_review': totalReview,
      'category_name': categoryName,
      'attributes': attributes != null && attributes!.isNotEmpty
          ? attributes!.map((String s) => s).join(', ')
          : null,
      'address': address,
      'open_hours': openHours,
      'website_url': websiteUrl,
      'phone_number': phoneNumber,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }

  static Result fromRow(Row row) {
    return Result(
      id: row['id'] as int,
      key: row['key'],
      label: row['label'],
      keyword: row['keyword'],
      title: row['title'],
      subTitle: row['sub_title'],
      star: row['star'] != null ? double.tryParse(row['star']) : null,
      totalReview: row['total_review'],
      categoryName: row['category_name'],
      attributes: (row['attributes'] ?? '').split(','),
      address: row['address'],
      openHours: row['open_hours'],
      websiteUrl: row['website_url'],
      phoneNumber: row['phone_number'],
      imageUrl: row['image_url'],
      createdAt: DateTime.tryParse(row['created_at']),
    );
  }
}
