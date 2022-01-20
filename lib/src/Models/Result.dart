import 'package:hive/hive.dart';

part 'result.g.dart';

@HiveType(typeId: 0)
class Result {
  @HiveField(0)
  String? key;

  @HiveField(1)
  String? label;

  @HiveField(2)
  String keyword;

  @HiveField(3)
  String? title;

  @HiveField(4)
  String? subTitle;

  @HiveField(5)
  double? star;

  @HiveField(6)
  int? totalReview;

  @HiveField(7)
  String? categoryName;

  @HiveField(8)
  List<String>? attributes;

  @HiveField(9)
  String? address;

  @HiveField(10)
  String? openHours;

  @HiveField(11)
  String? websiteUrl;

  @HiveField(12)
  String? phoneNumber;

  @HiveField(13)
  String? imageUrl;

  @HiveField(14)
  DateTime? createdAt;

  Result({
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
}
