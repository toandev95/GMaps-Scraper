class User {
  List<String>? deviceIds;
  String? name;
  String? email;
  DateTime? expiresAt;
  bool? trial;

  User({
    this.deviceIds,
    this.name,
    this.email,
    this.expiresAt,
    this.trial,
  });

  static User fromArray(List<String> ls) {
    return User(
      deviceIds: ls[0].split('&&'),
      name: ls[1],
      email: ls[2],
      expiresAt: DateTime.parse(ls[3]),
      trial: ls[4] == 'trial',
    );
  }
}
