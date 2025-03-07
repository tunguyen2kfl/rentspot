import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/pages/AdminUser/updateBuilding.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/stores/userData.dart';

class BuildingInformationView extends StatefulWidget {
  const BuildingInformationView({Key? key}) : super(key: key);

  @override
  _BuildingInformationViewState createState() =>
      _BuildingInformationViewState();
}

class _BuildingInformationViewState extends State<BuildingInformationView> {
  String buildingName = '';
  String address = '';
  String website = '';
  String email = '';
  String phone = '';
  String inviteCode = '';
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final BuildingApi buildingApi = BuildingApi(BuildingData());

  @override
  void initState() {
    super.initState();
    _loadBuildingData();
  }

  Future<void> _loadBuildingData() async {
    final buildingId = await storage.read(key: 'buildingId');
    if (buildingId != null) {
      try {
        Building building =
            await buildingApi.fetchBuildingById(int.parse(buildingId));
        setState(() {
          buildingName = building.name ?? "";
          address = building.address ?? "";
          website = building.website ?? "";
          email = building.email ?? "";
          phone = building.phone ?? "";
          inviteCode = building.inviteCode ?? "";
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load building data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    print(userData.role);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.apartment, color: Color(0xFF3DA9FC)),
              title: const Text('Building Name'),
              subtitle: Text(buildingName),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF3DA9FC)),
              title: const Text('Address'),
              subtitle: Text(address),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.web, color: Color(0xFF3DA9FC)),
              title: const Text('Website'),
              subtitle: Text(website),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF3DA9FC)),
              title: const Text('Email'),
              subtitle: Text(email),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF3DA9FC)),
              title: const Text('Phone'),
              subtitle: Text(phone),
            ),
            Divider(),
            if (userData.role == "building-admin") ...[
              ListTile(
                leading: const Icon(Icons.card_giftcard, color: Color(0xFF3DA9FC)),
                title: const Text('Invite Code'),
                subtitle: Text(inviteCode),
              ),
            ],
            const SizedBox(height: 40),
            Center(
              child: userData.role == "building-admin" ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateBuildingView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3DA9FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(0, 50),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ) : null,
            ),
          ],
        ),
      ),
    );
  }
}
