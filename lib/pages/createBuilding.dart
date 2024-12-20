import 'package:flutter/material.dart';
import 'dart:math';

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
    // hintStyle: TextStyle(color: Colors.grey), // Change hint color to grey
  );

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Print all field values
      print('Building Name: ${_buildingNameController.text}');
      print('Address: ${_addressController.text}');
      print('Website: ${_websiteController.text}');
      print('Email: ${_emailController.text}');
      print('Phone: ${_phoneController.text}');
      print('Invite Code: ${_inviteCodeController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    _generateInviteCode();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Building'),
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
                  const SizedBox(height: 16.0), // Add spacing
                  TextFormField(
                    controller: _addressController,
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Address'),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  TextFormField(
                    controller: _websiteController,
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Website'),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  TextFormField(
                    controller: _emailController,
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  TextFormField(
                    controller: _phoneController,
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  TextFormField(
                      controller: _inviteCodeController,
                      decoration: customInputDecoration.copyWith(
                        labelText: 'Invite Code',
                        suffixIcon: IconButton(
                          // Add suffixIcon here
                          icon: const Icon(Icons.refresh),
                          onPressed:
                              _generateInviteCode, // Call _generateInviteCode on press
                        ),
                      ),
                      readOnly: true),
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for Login
                        _submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _textFieldBorderColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: Size(0, 50),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18, // Set your desired font size here
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
