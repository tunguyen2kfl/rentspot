import 'package:flutter/material.dart';
import 'dart:math';

class UpdateBuildingView extends StatefulWidget {
  const UpdateBuildingView({Key? key}) : super(key: key);

  @override
  _UpdateBuildingViewState createState() => _UpdateBuildingViewState();
}

const double _textFieldBorderRadius = 10;
const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;

class _UpdateBuildingViewState extends State<UpdateBuildingView> {
  final _formKey = GlobalKey<FormState>();
  final _buildingNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteCodeController = TextEditingController();

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

  void _loadBuildingData() {
    // Giả lập tải dữ liệu tòa nhà - thay thế bằng dữ liệu thực tế
    _buildingNameController.text = 'Building A';
    _addressController.text = '123 Example Street';
    _websiteController.text = 'www.example.com';
    _emailController.text = 'contact@example.com';
    _phoneController.text = '123456789';
    _inviteCodeController.text = 'ABCDE12345'; // Giả lập mã mời
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // In ra tất cả các giá trị trường
      print('Building Name: ${_buildingNameController.text}');
      print('Address: ${_addressController.text}');
      print('Website: ${_websiteController.text}');
      print('Email: ${_emailController.text}');
      print('Phone: ${_phoneController.text}');
      print('Invite Code: ${_inviteCodeController.text}');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBuildingData(); // Tải dữ liệu khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Building'),
        ),
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
                    decoration: customInputDecoration.copyWith(
                        labelText: 'Building Name'),
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
                    decoration:
                    customInputDecoration.copyWith(labelText: 'Address'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _websiteController,
                    decoration:
                    customInputDecoration.copyWith(labelText: 'Website'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration:
                    customInputDecoration.copyWith(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                    customInputDecoration.copyWith(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                      controller: _inviteCodeController,
                      decoration: customInputDecoration.copyWith(
                        labelText: 'Invite Code',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            // Có thể thêm logic để tạo mã mời mới nếu cần
                          },
                        ),
                      ),
                      readOnly: true),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: _submitForm,
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
        ));
  }
}