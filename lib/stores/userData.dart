import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/models/user.dart';

class UserData with ChangeNotifier {
  num? _id;
  String? _accessToken;
  String? _username;
  String? _email;
  String? _displayName;
  String? _avatar;
  num? _buildingId;
  List<String>? _buildings;
  dynamic _role;

  final storage = FlutterSecureStorage();

  Future<void> loadUserData() async {
    try {
      print('Loading user data...');
      _accessToken = await storage.read(key: 'accessToken');
      _username = await storage.read(key: 'username');
      _email = await storage.read(key: 'email');
      _avatar = await storage.read(key: 'avatar');
      _displayName = await storage.read(key: 'displayName');
      String? idString = await storage.read(key: 'id');
      if (idString != null) {
        print('idString $idString');
        _id = int.parse(idString);
      } else {
        print('ID not found');
      }
      String? idBuildingString = await storage.read(key: 'buildingId');
      if (idBuildingString != null) {
        print('idString $idBuildingString');
        _buildingId = int.parse(idBuildingString);
      } else {
        print('ID not found');
      }
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
    print("Start set USER infor");
    _username = user.username;
    _email = user.email;
    _displayName = user.displayName;
    _role = user.role;
    _id = user.id;
    _avatar = user.avatar;
    _buildingId = user.buildingId;

    // Lưu trữ tất cả thông tin vào storage
    await storage.write(key: 'id', value: _id.toString());
    await storage.write(key: 'username', value: _username);
    await storage.write(key: 'email', value: _email);
    await storage.write(key: 'displayName', value: _displayName);
    await storage.write(key: 'avatar', value: _avatar);
    await storage.write(key: 'buildingId', value: _buildingId.toString());
    await storage.write(
        key: 'role', value: _role.toString()); // Chuyển đổi nếu cần

    notifyListeners();
  }

  String? get accessToken => _accessToken;
  String? get username => _username;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get avatar => _avatar;
  num? get buildingId => _buildingId;
  num? get id => _id;
  List<String>? get buildings => _buildings;
  dynamic get role => _role;

  void clear() async {
    _accessToken = null;
    _username = null;
    _email = null;
    _displayName = null;
    _role = null;
    _id = null;
    _avatar = null;
    _buildingId = null;
    await storage.deleteAll();
    notifyListeners();
  }
}
