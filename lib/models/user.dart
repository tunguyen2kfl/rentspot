class User {
  final num? id;
  final String? username;
  final String? password;
  final String? email;
  final String? displayName;
  final num? buildingId;
  final dynamic role;

  User({
    this.id,
    this.username,
    this.password,
    this.email,
    this.displayName,
    this.role,
    this.buildingId
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      displayName: json['displayName'],
      role: json['role'],
      buildingId: json['buildingId']
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
      'buildingId': buildingId
    };
  }
}