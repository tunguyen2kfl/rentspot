class Building {
  final int? id; // Thêm trường id
  final String? name;
  final String? address;
  final String? website;
  final String? email;
  final String? phone;
  final String? inviteCode;

  Building({
    this.id, // Khởi tạo id
    this.name,
    this.address,
    this.website,
    this.email,
    this.phone,
    this.inviteCode,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'], // Lấy id từ json
      name: json['name'],
      address: json['address'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      inviteCode: json['inviteCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Chuyển đổi id thành json
      'name': name,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'inviteCode': inviteCode,
    };
  }
}