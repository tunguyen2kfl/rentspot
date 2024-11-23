import 'package:flutter/material.dart';
import 'dart:math';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/models/building.dart'; // Import model Building
import 'package:rent_spot/api/buildingApi.dart'; // Import BuildingApi
import 'package:rent_spot/api/userApi.dart'; // Import UserApi
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/stores/userData.dart';

class CreateBuildingView extends StatefulWidget {
  const CreateBuildingView({Key? key}) : super(key: key);

  @override
  _CreateBuildingViewState createState() => _CreateBuildingViewState();
}

const double _textFieldBorderRadius = 10;
const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;

class _CreateBuildingViewState extends State<CreateBuildingView> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _buildingNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  final BuildingApi buildingApi = BuildingApi(BuildingData()); // Khởi tạo BuildingApi
  final UserApi userApi = UserApi(UserData()); // Khởi tạo UserApi
  bool _isLoading = false; // Biến để theo dõi trạng thái loading

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

  // Reusable input decoration
  final InputDecoration customInputDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: TextStyle(color: Colors.grey),
  );

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Đặt trạng thái loading
      });

      // Tạo đối tượng Building
      Building newBuilding = Building(
        name: _buildingNameController.text.trim(),
        address: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        inviteCode: _inviteCodeController.text.trim(),
      );


      // Gọi API để thêm tòa nhà
      bool success = await buildingApi.addBuilding(newBuilding);

      // Hiển thị thông báo
      if (success) {
        _showSnackBar('Building created successfully!');

        // Gọi API để lấy thông tin người dùng
        try {
          User user = await userApi.getUserInfo();
          print("User info obtained: ${user.username}"); // Kiểm tra thông tin người dùng

          // Chuyển tiếp đến màn hình WaitingScheduleView
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainAdminScreen()),
          );
        } catch (e) {
          _showSnackBar('Failed to get user information. Please try again.');
          print("Error fetching user info: $e");
        }
      } else {
        _showSnackBar('Failed to create building. Please try again.');
      }

      setState(() {
        _isLoading = false; // Đặt lại trạng thái loading
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateInviteCode(); // Sinh mã mời mỗi khi build, có thể cần điều chỉnh
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Create Building",
        onSidebarButtonPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState!.openDrawer(); // Mở sidebar
          }
        },
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: const SideMenu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: _buildingNameController,
                      decoration: customInputDecoration.copyWith(
                          labelText: 'Building Name'),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _addressController,
                      decoration: customInputDecoration.copyWith(labelText: 'Address'),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _websiteController,
                      decoration: customInputDecoration.copyWith(labelText: 'Website'),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: customInputDecoration.copyWith(labelText: 'Email'),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _phoneController,
                      decoration: customInputDecoration.copyWith(labelText: 'Phone'),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _inviteCodeController,
                      decoration: customInputDecoration.copyWith(
                        labelText: 'Invite Code',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _generateInviteCode,
                        ),
                      ),
                      readOnly: true,
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10, right: 16, left: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : () {
                _submitForm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _textFieldBorderColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: Size(0, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}