import 'package:flutter/material.dart';
import 'package:rent_spot/pages/AdminUser/updateBuilding.dart';

class BuildingInformationView extends StatefulWidget {
  const BuildingInformationView({Key? key}) : super(key: key);

  @override
  _BuildingInformationViewState createState() => _BuildingInformationViewState();
}

class _BuildingInformationViewState extends State<BuildingInformationView> {
  String buildingName = '';
  String address = '';
  String website = '';
  String email = '';
  String phone = '';
  String inviteCode = '';

  @override
  void initState() {
    super.initState();
    _loadBuildingData(); // Gọi hàm để tải dữ liệu
  }

  void _loadBuildingData() {
    // Giả lập tải dữ liệu từ API hoặc cơ sở dữ liệu
    setState(() {
      buildingName = 'Building A';
      address = '123 Example Street';
      website = 'www.example.com';
      email = 'contact@example.com';
      phone = '123456789';
      inviteCode = 'ABCDE12345'; // Giả lập mã mời
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.apartment, color: Color(0xFF3DA9FC)),
              title: Text('Building Name'),
              subtitle: Text(buildingName),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on, color: Color(0xFF3DA9FC)),
              title: Text('Address'),
              subtitle: Text(address),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.web, color: Color(0xFF3DA9FC)),
              title: Text('Website'),
              subtitle: Text(website),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF3DA9FC)),
              title: Text('Email'),
              subtitle: Text(email),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF3DA9FC)),
              title: Text('Phone'),
              subtitle: Text(phone),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.card_giftcard, color: Color(0xFF3DA9FC)),
              title: Text('Invite Code'),
              subtitle: Text(inviteCode),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateBuildingView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3DA9FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(0, 50),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}