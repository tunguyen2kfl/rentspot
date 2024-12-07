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
      startTime: json['startTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse(json['startTime'])) : null,
      endTime: json['endTime'] != null ? TimeOfDay.fromDateTime(DateTime.parse(json['endTime'])) : null,
      attendees: json['attendees'],
      organizer: json['organizer'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
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
      'startTime': startTime != null ? DateTime(0, 0, 0, startTime!.hour, startTime!.minute).toIso8601String() : null,
      'endTime': endTime != null ? DateTime(0, 0, 0, endTime!.hour, endTime!.minute).toIso8601String() : null,
      'attendees': attendees,
      'organizer': organizer,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isDeleted': isDeleted,
    };
  }
}