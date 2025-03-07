class Device {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final int? createdBy;
  final int? updatedBy;
  final bool? isDeleted;

  Device({
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdBy,
    this.updatedBy,
    this.isDeleted,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isDeleted': isDeleted,
    };
  }
}