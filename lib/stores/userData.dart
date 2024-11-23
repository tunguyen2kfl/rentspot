import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/models/user.dart';

class UserData with ChangeNotifier {
  String? _accessToken;
  String? _username;
  String? _email;
  String? _displayName;
  String? _avatar;
  List<String>? _buildings;
  dynamic _role;

  final storage = FlutterSecureStorage();

  Future<void> loadUserData() async {
    try {
      print('Loading user data...');
      _accessToken = await storage.read(key: 'accessToken');
      _username = await storage.read(key: 'username');
      _email = await storage.read(key: 'email');
      _displayName = await storage.read(key: 'displayName');
      _role = await storage.read(key: 'role');
      print('User data loaded');
      notifyListeners();
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await storage.write(key: 'accessToken', value: token);
    notifyListeners();
  }

  // Thêm phương thức setUserInfo để lưu toàn bộ thông tin User
  Future<void> setUserInfo(User user) async {
    _username = user.username;
    _email = user.email;
    _displayName = user.displayName;
    _role = user.role;

    // Lưu trữ tất cả thông tin vào storage
    await storage.write(key: 'username', value: _username);
    await storage.write(key: 'email', value: _email);
    await storage.write(key: 'displayName', value: _displayName);
    await storage.write(
        key: 'role', value: _role.toString()); // Chuyển đổi nếu cần

    notifyListeners();
  }

  String? get accessToken => _accessToken;
  String? get username => _username;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get avatar => _avatar;
  List<String>? get buildings => _buildings;
  dynamic get role => _role;

  void clear() async {
    _accessToken = null;
    _username = null;
    _email = null;
    _displayName = null;
    _role = null;
    await storage.deleteAll();
    notifyListeners();
  }
}
