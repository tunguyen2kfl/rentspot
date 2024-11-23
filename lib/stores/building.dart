import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/models/building.dart';

class BuildingData with ChangeNotifier {
  String? _name;
  String? _address;
  String? _website;
  String? _email;
  String? _phone;
  String? _inviteCode;

  final storage = FlutterSecureStorage();

  Future<void> loadBuildingData() async {
    try {
      print('Loading building data...');
      _name = await storage.read(key: 'buildingName');
      _address = await storage.read(key: 'buildingAddress');
      _website = await storage.read(key: 'buildingWebsite');
      _email = await storage.read(key: 'buildingEmail');
      _phone = await storage.read(key: 'buildingPhone');
      _inviteCode = await storage.read(key: 'buildingInviteCode');
      print('Building data loaded');
      notifyListeners();
    } catch (e) {
      print("Error loading building data: $e");
    }
  }

  Future<void> setBuildingInfo(Building building) async {
    _name = building.name;
    _address = building.address;
    _website = building.website;
    _email = building.email;
    _phone = building.phone;
    _inviteCode = building.inviteCode;

    // Lưu trữ tất cả thông tin vào storage
    await storage.write(key: 'buildingName', value: _name);
    await storage.write(key: 'buildingAddress', value: _address);
    await storage.write(key: 'buildingWebsite', value: _website);
    await storage.write(key: 'buildingEmail', value: _email);
    await storage.write(key: 'buildingPhone', value: _phone);
    await storage.write(key: 'buildingInviteCode', value: _inviteCode);

    notifyListeners();
  }

  // Các getter
  String? get name => _name;
  String? get address => _address;
  String? get website => _website;
  String? get email => _email;
  String? get phone => _phone;
  String? get inviteCode => _inviteCode;

  void clear() async {
    _name = null;
    _address = null;
    _website = null;
    _email = null;
    _phone = null;
    _inviteCode = null;
    await storage.deleteAll();
    notifyListeners();
  }
}