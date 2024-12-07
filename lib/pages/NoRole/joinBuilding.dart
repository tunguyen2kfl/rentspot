import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm import cho Provider
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/stores/userData.dart';

const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;
const double _textFieldBorderRadius = 10;

// Reusable input decoration
final InputDecoration customInputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
        BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
        BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  labelStyle: TextStyle(color: _textFieldBorderColor),
  prefixIcon: Icon(Icons.code, color: _textFieldBorderColor),
);

class JoinBuildingView extends StatefulWidget {
  @override
  _JoinBuildingViewState createState() => _JoinBuildingViewState();
}

class _JoinBuildingViewState extends State<JoinBuildingView> {
  final TextEditingController _buildingCodeController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Building? _building;
  final UserApi userApi = UserApi(UserData());

  Future<void> _getUserInfo() async {
    try {
      User user = await userApi.getUserInfo(context);
      print("User Info: ${user.toString()}");
    } catch (e) {
      print("Error getting user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildingApi = BuildingApi(BuildingData());

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Join Building",
        onSidebarButtonPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: const SideMenu(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/Logo.png',
                  height: 150,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Join building using the invite code',
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextField(
                  controller: _buildingCodeController,
                  decoration: customInputDecoration.copyWith(
                      labelText: 'Building Code'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String buildingCode = _buildingCodeController.text;
                    print('Joining building with code: $buildingCode');

                    // Gọi hàm joinBuilding
                    try {
                      Building joinedBuilding =
                          await buildingApi.joinBuilding(buildingCode);

                      if (joinedBuilding != null) {
                        await _getUserInfo();
                        _building = new Building(
                            id: joinedBuilding.id,
                            name: joinedBuilding.name,
                            email: joinedBuilding.email,
                            address: joinedBuilding.address);
                        _showBuildingInfo(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to join building')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to join building')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3DA9FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuildingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Building Information'),
          content: _building != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Building Name: ${_building!.name}'),
                    Text('Building Address: ${_building!.address}'),
                    // Thêm các thông tin khác của tòa nhà nếu cần
                  ],
                )
              : Text('No building information available.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3DA9FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
