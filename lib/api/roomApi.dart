import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rent_spot/stores/userData.dart';


class RoomApi {
  final String baseUrl;
  final UserData userData;

  RoomApi(this.baseUrl, this.userData);

  Future<List<dynamic>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms'),
      headers: {
        'Authorization': 'Bearer ${userData.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<dynamic> get(String roomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms/$roomId'),
      headers: {
        'Authorization': 'Bearer ${userData.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load room');
    }
  }
}