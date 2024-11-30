import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/device.dart'; // Import model Device
import 'dart:convert';
import 'package:rent_spot/stores/userData.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class DeviceApi {
  final String baseUrl = Constants.apiUrl;
  final UserData userData;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  DeviceApi(this.userData);

  // Lấy accessToken từ FlutterSecureStorage
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken'); // Lấy accessToken
  }

  Future<List<Device>> getAll() async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/devices'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((deviceJson) => Device.fromJson(deviceJson)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<Device> get(String deviceId) async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/devices/$deviceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return Device.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load device');
    }
  }

  Future<Device> create(Device device, File? imageFile) async {
    final accessToken = await _getAccessToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/devices'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = device.name ?? '';
    request.fields['description'] = device.description ?? '';

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 201) {
      return Device.fromJson(jsonDecode(responseBody.body));
    } else {
      throw Exception('Failed to create device: ${responseBody.body}');
    }
  }

  Future<Device> update(Device device, File? imageFile) async {
    final accessToken = await _getAccessToken();
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/devices/${device.id}'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = device.name ?? '';
    request.fields['description'] = device.description ?? '';

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return Device.fromJson(jsonDecode(responseBody.body));
    } else {
      throw Exception('Failed to update device: ${responseBody.body}');
    }
  }

  Future<void> delete(int? deviceId) async {
    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/devices/$deviceId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) { // 204 No Content là thành công
      throw Exception('Failed to delete device: ${response.body}');
    }
  }
}