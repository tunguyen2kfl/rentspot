import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/building.dart';
import 'dart:convert';
import 'package:rent_spot/stores/building.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BuildingApi {
  final String baseUrl = Constants.apiUrl;
  final BuildingData buildingData;
  final FlutterSecureStorage storage = FlutterSecureStorage(); // Khởi tạo FlutterSecureStorage

  BuildingApi(this.buildingData);

  // Lấy accessToken từ FlutterSecureStorage
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken'); // Lấy accessToken
  }

  // Lấy thông tin tòa nhà theo ID
  Future<bool> fetchBuildingById(int id) async {
    final accessToken = await _getAccessToken(); // Lấy accessToken
    final response = await http.get(
      Uri.parse('$baseUrl/api/buildings/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken', // Thêm accessToken vào header
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final building = Building.fromJson(json);
      await buildingData.setBuildingInfo(building); // Nạp vào store
      return true; // Trả về true khi thành công
    } else {
      return false; // Trả về false khi thất bại
    }
  }

  // Thêm tòa nhà mới
  Future<bool> addBuilding(Building building) async {
    final accessToken = await _getAccessToken(); // Lấy accessToken
    print(accessToken);
    final response = await http.post(
      Uri.parse('$baseUrl/api/buildings'),
      body: jsonEncode(building.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Thêm accessToken vào header
      },
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final newBuilding = Building.fromJson(json['building']); // Lấy thông tin tòa nhà từ phản hồi
      await buildingData.setBuildingInfo(newBuilding); // Nạp vào store
      return true; // Trả về true khi thành công
    } else {
      return false; // Trả về false khi thất bại
    }
  }

  // Cập nhật tòa nhà
  Future<bool> updateBuilding(int id, Building building) async {
    final accessToken = await _getAccessToken(); // Lấy accessToken
    final response = await http.put(
      Uri.parse('$baseUrl/api/buildings/$id'),
      body: jsonEncode(building.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Thêm accessToken vào header
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final updatedBuilding = Building.fromJson(json['building']); // Cập nhật thông tin tòa nhà từ phản hồi
      await buildingData.setBuildingInfo(updatedBuilding); // Nạp vào store
      return true; // Trả về true khi thành công
    } else {
      return false; // Trả về false khi thất bại
    }
  }

  Future<void> deleteBuilding(int id) async {
    final accessToken = await _getAccessToken(); // Lấy accessToken
    final response = await http.delete(
      Uri.parse('$baseUrl/api/buildings/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken', // Thêm accessToken vào header
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete building: ${response.statusCode}');
    }
  }
}