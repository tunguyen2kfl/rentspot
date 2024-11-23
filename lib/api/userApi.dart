import 'package:http/http.dart' as http;
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';
import 'dart:convert'; // Import class UserData

class UserApi {
  final String baseUrl = "http://10.0.2.2:8080";
  final UserData userData;

  UserApi(this.userData);

  Future<String> login(String username, String password) async {
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
      return accessToken;
    } else {
      throw Exception('Failed to login');
    }
  }
}