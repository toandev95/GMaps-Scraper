class District {
  int? id;
  String? name;

  District({
    this.id,
    this.name,
  });

  static District fromMap(dynamic json) {
    return District(
      id: (json['id'] as int),
      name: (json['name'] as String),
    );
  }
}
