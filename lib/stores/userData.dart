import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserData with ChangeNotifier {
  String? _accessToken;
  String? _username;

  final storage = FlutterSecureStorage();

  Future<void> loadUserData() async {
    _accessToken = await storage.read(key: 'accessToken');
    _username = await storage.read(key: 'username');
    notifyListeners();
  }

  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await storage.write(key: 'accessToken', value: token);
    notifyListeners();
  }

  String? get accessToken => _accessToken;
  String? get username => _username;

  void clear() async {
    _accessToken = null;
    _username = null;
    await storage.deleteAll();
    notifyListeners();
  }
}