// lib/models/schedule.dart
class Schedule {
  final int id;
  final String summary;
  final DateTime date;
  final int resourceId;
  final String status;
  final String? color;
  final DateTime startTime;
  final DateTime endTime;
  final String organizer;

  Schedule({
    required this.id,
    required this.summary,
    required this.date,
    required this.resourceId,
    required this.status,
    this.color,
    required this.startTime,
    required this.endTime,
    required this.organizer
  });
}