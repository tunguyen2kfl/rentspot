import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/room.dart';
import 'dart:convert';
import 'package:rent_spot/stores/userData.dart';

class RoomApi {
  final String baseUrl = Constants.apiUrl;
  final UserData userData;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  RoomApi(this.userData);

  // Lấy accessToken từ FlutterSecureStorage
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken'); // Lấy accessToken
  }

  Future<List<Room>> getAll() async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');
    print(buildingId);
    final response = await http.get(
      Uri.parse('$baseUrl/api/rooms?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer ${accessToken}',
      }
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((roomJson) => Room.fromJson(roomJson)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<Room> get(String roomId) async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/rooms/$roomId'),
      headers: {
        'Authorization': 'Bearer ${accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load room');
    }
  }

  Future<Room> create(Room room) async {
    final accessToken = await _getAccessToken();
    String? buildingId = await storage.read(key: 'buildingId');
    print('$baseUrl/api/rooms?buildingId=$buildingId');
    final response = await http.post(
      Uri.parse('$baseUrl/api/rooms?buildingId=$buildingId'),
      headers: {
        'Authorization': 'Bearer ${accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(room.toJson()),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create room: ${response.body}');
    }
  }

  Future<Room> update(Room room) async {
    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/rooms/${room.id}'),
      headers: {
        'Authorization': 'Bearer ${accessToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(room.toJson()),
    );

    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update room: ${response.body}');
    }
  }

  Future<void> delete(int? roomId) async {
    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/rooms/$roomId'),
      headers: {
        'Authorization': 'Bearer ${accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete room: ${response.body}');
    }
  }
}