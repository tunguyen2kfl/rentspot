class Building {
  final String? name;
  final String? address;
  final String? website;
  final String? email;
  final String? phone;
  final String? inviteCode;

  Building({
    this.name,
    this.address,
    this.website,
    this.email,
    this.phone,
    this.inviteCode,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
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
      'name': name,
      'address': address,
      'website': website,
      'email': email,
      'phone': phone,
      'inviteCode': inviteCode,
    };
  }
}