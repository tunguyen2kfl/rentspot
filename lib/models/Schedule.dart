import 'package:flutter/material.dart';

class Schedule {
  final int? id;
  final String? summary;
  final DateTime? date;
  final int? roomId;
  final int? buildingId;
  final String? status;
  final String? color;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? attendees;
  final int? organizer;
  final int? createdBy;
  final int? updatedBy;
  final bool? isDeleted;
  final String? description;

  Schedule({
    this.id,
    required this.summary,
    this.date,
    this.roomId,
    this.buildingId,
    this.status,
    this.color,
    this.startTime,
    this.endTime,
    this.attendees,
    this.organizer,
    this.createdBy,
    this.updatedBy,
    this.isDeleted,
    this.description,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      summary: json['summary'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      roomId: json['roomId'],
      buildingId: json['buildingId'],
      status: json['status'],
      color: json['color'],
      startTime: json['startTime'] != null ? _convertToTimeOfDay(json['startTime']) : null,
      endTime: json['endTime'] != null ? _convertToTimeOfDay(json['endTime']) : null,
      attendees: json['attendees'],
      organizer: json['organizer'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'date': date?.toIso8601String(),
      'roomId': roomId,
      'buildingId': buildingId,
      'status': status,
      'color': color,
      'startTime': startTime != null ? _convertToTimeString(startTime!) : null,
      'endTime': endTime != null ? _convertToTimeString(endTime!) : null,
      'attendees': attendees,
      'organizer': organizer,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isDeleted': isDeleted,
      'description': description,
    };
  }

  static TimeOfDay _convertToTimeOfDay(String time) {
    final parts = time.split(':');

    if (parts.length < 2 || parts.length > 3) {
      throw FormatException('Invalid time format: $time');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _convertToTimeString(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }
}