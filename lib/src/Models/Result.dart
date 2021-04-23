class Result {
  int? keywordId;
  int? provinceId;
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
    this.keywordId,
    this.provinceId,
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
}
