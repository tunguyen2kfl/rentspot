import 'package:http/http.dart' as http;
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';
import 'dart:convert';

class UserApi {
  final String baseUrl = "http://10.0.2.2:8080";
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

  // Hàm để lấy thông tin người dùng
  Future<User> getUserInfo() async {
    await userData.loadUserData();
    final accessToken = userData.accessToken; // Lấy accessToken từ UserData
    print(accessToken);
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/infor'), // Đường dẫn API lấy thông tin người dùng
      headers: {
        'Authorization': 'Bearer $accessToken', // Thêm accessToken vào header
        'Content-Type': 'application/json',
      },
    );

    print('Get User Info Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      User user = User.fromJson(data);
      await userData.setUserInfo(user); // Cập nhật thông tin người dùng
      return user;
    } else {
      throw Exception('Failed to get user information');
    }
  }
}