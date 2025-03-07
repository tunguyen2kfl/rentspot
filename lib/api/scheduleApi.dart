import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'dart:convert';
import 'package:rent_spot/stores/userData.dart';

class ScheduleApi {
  final String baseUrl = Constants.apiUrl;
  final UserData userData;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  ScheduleApi(this.userData);

  // Lấy accessToken từ FlutterSecureStorage
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken'); // Lấy accessToken
  }

  Future<List<Schedule>> getAll() async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((scheduleJson) => Schedule.fromJson(scheduleJson)).toList();
    } else {
      throw Exception('Failed to load schedules: ${response.body}');
    }
  }

  Future<List<Schedule>> getMySchedules() async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules/my?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((scheduleJson) => Schedule.fromJson(scheduleJson)).toList();
    } else {
      throw Exception('Failed to load schedules: ${response.body}');
    }
  }

  Future<Schedule> get(String scheduleId) async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load schedule: ${response.body}');
    }
  }

  Future<Schedule> create(Schedule schedule) async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');

    final scheduleData = {
      'summary': schedule.summary,
      'date': schedule.date?.toIso8601String(),
      'roomId': schedule.roomId,
      'buildingId': buildingId,
      'status': schedule.status,
      'color': schedule.color,
      'startTime': _formatTime(schedule.startTime),
      'endTime': _formatTime(schedule.endTime),
      'attendees': schedule.attendees,
      'organizer': schedule.organizer,
      'createdBy': schedule.createdBy,
      'updatedBy': schedule.updatedBy,
      'isDeleted': schedule.isDeleted,
      'description': schedule.description
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/schedules?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(scheduleData),
    );

    if (response.statusCode == 201) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create schedule: ${response.body}');
    }
  }

  Future<Schedule> update(Schedule schedule) async {
    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/schedules/${schedule.id}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update schedule: ${response.body}');
    }
  }

  Future<void> delete(int? scheduleId) async {
    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/schedules/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule: ${response.body}');
    }
  }

  Future<List<Schedule>> getWaitingSchedules() async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');

    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules/waitting?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((scheduleJson) => Schedule.fromJson(scheduleJson)).toList();
    } else {
      throw Exception('Failed to load waiting schedules: ${response.body}');
    }
  }

  Future<Schedule> passWaitingSchedules(String scheduleId) async {
    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/schedules/check/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to pass waiting schedule: ${response.body}');
    }
  }

  Future<Schedule> cancelWaitingSchedules(String scheduleId) async {
    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/schedules/cancel/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to cancel waiting schedule: ${response.body}');
    }
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}