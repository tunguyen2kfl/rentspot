import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/login.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class UserApi {
  final String baseUrl = Constants.apiUrl;
  final UserData userData;

  UserApi(this.userData);

  Future<User> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String accessToken = data['token'];
      User user = User.fromJson(data['user']);
      await userData.setAccessToken(accessToken);
      await userData.setUserInfo(user);
      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<bool> register(String username, String password, String email,
      String displayName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        'displayName': displayName
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<User> getUserInfo(BuildContext context) async {
    final accessToken = await storage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/infor'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Get User Info Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      User user = User.fromJson(data);
      await userData.setUserInfo(user);
      return user;
    } else {
      // Xử lý lỗi từ response
      await storage.deleteAll();
      _navigateToLogin(context);
      throw Exception('Failed to get user information: ${response.statusCode}');
    }
  }

  Future<List<User>> getAllUserInBuilding(BuildContext context) async {
    final accessToken = await storage.read(key: 'accessToken');
    final buildingId = await storage.read(key: 'buildingId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/allSelect?buildingId=$buildingId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<User> users =
            data.map((userJson) => User.fromJson(userJson)).toList();
        return users;
      } else {
        showErrorSnackbar(
            context, 'Failed to get users: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      showErrorSnackbar(context, 'Error occurred: $error');
      return [];
    }
  }

  Future<User> updateProfile(User user, File? imageFile) async {
    final accessToken = await storage.read(key: 'accessToken');
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/api/users/profile'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';

    request.fields['name'] = user.displayName ?? '';
    request.fields['website'] = user.website ?? '';
    request.fields['email'] = user.email ?? '';
    request.fields['phone'] = user.phone ?? '';

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
      print(jsonDecode(responseBody.body)['user']);
      User user = User.fromJson(jsonDecode(responseBody.body)['user']);
      await userData.setUserInfo(user);
      return user;
    } else {
      throw Exception('Failed to update profile: ${responseBody.body}');
    }
  }

  Future<bool> removeUserFromBuilding(String? id) async {
    final buildingId = await storage.read(key: 'buildingId');
    final accessToken = await storage.read(key: 'accessToken');
    final response = await http.delete(
      Uri.parse('$baseUrl/api/users/removeUserFromBuilding/$id?buildingId=$buildingId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }


  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
