class User {
  final num? id;
  final String? username;
  final String? password;
  final String? email;
  final String? displayName;
  final num? buildingId;
  final dynamic role;
  final String? avatar;
  final String? website;
  final String? phone;

  User({
    this.id,
    this.username,
    this.password,
    this.email,
    this.displayName,
    this.role,
    this.buildingId,
    this.avatar,
    this.website,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      displayName: json['displayName'],
      role: json['role'],
      buildingId: json['buildingId'],
      avatar: json['avatar'],
      website: json['website'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'displayName': displayName,
      'role': role,
      'buildingId': buildingId,
      'avatar': avatar,
      'website': website,
      'phone': phone,
    };
  }
}