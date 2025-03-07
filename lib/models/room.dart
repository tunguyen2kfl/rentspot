class Room {
  final int? id;
  final String? name;
  final bool? isOpen;
  final int? buildingId;
  final String? status;
  final String? description;
  final int? createdBy;
  final int? updatedBy;
  final bool? isDeleted;
  final String? devices;

  Room({
    this.id,
    this.name,
    this.isOpen,
    this.buildingId,
    this.status,
    this.description,
    this.createdBy,
    this.updatedBy,
    this.isDeleted,
    this.devices,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      isOpen: json['isOpen'],
      buildingId: json['buildingId'],
      status: json['status'],
      description: json['description'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      devices: json['devices'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOpen': isOpen,
      'buildingId': buildingId,
      'status': status,
      'description': description,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isDeleted': isDeleted,
      'devices': devices,
    };
  }
}