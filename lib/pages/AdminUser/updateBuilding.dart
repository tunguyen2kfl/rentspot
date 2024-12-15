import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/stores/building.dart';

class UpdateBuildingView extends StatefulWidget {
  const UpdateBuildingView({Key? key}) : super(key: key);

  @override
  _UpdateBuildingViewState createState() => _UpdateBuildingViewState();
}

const Color _textFieldBorderColor = Color(0xFF3DA9FC);

class _UpdateBuildingViewState extends State<UpdateBuildingView> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _buildingNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final BuildingApi buildingApi = BuildingApi(BuildingData());

  @override
  void dispose() {
    _buildingNameController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _generateInviteCode() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final inviteCode = String.fromCharCodes(Iterable.generate(
      10, // Length of the invite code
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
    setState(() {
      _inviteCodeController.text = inviteCode;
    });
  }

  Future<void> _loadBuildingData() async {
    final buildingId = await storage.read(key: 'buildingId');
    if (buildingId != null) {
      try {
        Building building = await buildingApi.fetchBuildingById(int.parse(buildingId));
        _buildingNameController.text = building.name ?? "";
        _addressController.text = building.address ?? "";
        _websiteController.text = building.website ?? "";
        _emailController.text = building.email ?? "";
        _phoneController.text = building.phone ?? "";
        _inviteCodeController.text = building.inviteCode ?? "";
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load building data: $e')),
        );
      }
    }
  }

  Future<void> _updateBuilding() async {
    final buildingId = await storage.read(key: 'buildingId');
    if (buildingId != null) {
      Building updatedBuilding = Building(
        id: int.parse(buildingId),
        name: _buildingNameController.text,
        address: _addressController.text,
        website: _websiteController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        inviteCode: _inviteCodeController.text,
      );

      final success = await buildingApi.updateBuilding(int.parse(buildingId), updatedBuilding);
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainAdminScreen(initialPageIndex: 3),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Building updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update building.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBuildingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Update Building",
        onSidebarButtonPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState!.openDrawer();
          }
        },
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _buildingNameController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Building Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a building name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Address'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _websiteController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Website'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Email'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Phone'),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _inviteCodeController,
                  decoration: Constants.customInputDecoration.copyWith(
                    labelText: 'Invite Code',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _generateInviteCode();
                      },
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateBuilding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textFieldBorderColor,
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
        ),
      ),
    );
  }
}