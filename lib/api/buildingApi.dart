import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/building.dart';
import 'dart:convert';
import 'package:rent_spot/stores/building.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BuildingApi {
  final String baseUrl = Constants.apiUrl;
  final BuildingData buildingData;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  BuildingApi(this.buildingData);

  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<bool> fetchBuildingById(int id) async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/buildings/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final building = Building.fromJson(json);
      await buildingData.setBuildingInfo(building);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addBuilding(Building building) async {
    final accessToken = await _getAccessToken();
    print(accessToken);
    final response = await http.post(
      Uri.parse('$baseUrl/api/buildings'),
      body: jsonEncode(building.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final newBuilding = Building.fromJson(json['building']);
      await buildingData.setBuildingInfo(newBuilding);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateBuilding(int id, Building building) async {
    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/buildings/$id'),
      body: jsonEncode(building.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final updatedBuilding = Building.fromJson(json['building']);
      await buildingData.setBuildingInfo(updatedBuilding);
      return true;
    } else {
      return false;
    }
  }

  Future<Building> joinBuilding(String inviteCode) async {
    final accessToken = await _getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/buildings/join'),
      body: jsonEncode({'inviteCode': inviteCode}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final updatedBuilding = Building.fromJson(json['building']);
      await buildingData.setBuildingInfo(updatedBuilding);
      return updatedBuilding;
    } else {
      throw Exception('Failed to join building');
    }
  }

  Future<void> deleteBuilding(int id) async {
    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/buildings/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete building: ${response.statusCode}');
    }
  }
}
