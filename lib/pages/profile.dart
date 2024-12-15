import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'dart:io';

import 'package:rent_spot/stores/userData.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserApi userApi = UserApi(UserData());
  final FlutterSecureStorage storage = FlutterSecureStorage();
  File? _imageFile;

  User? user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      user = await userApi.getUserInfo(context);
      print("LoadUserInforProfile");
      print(user?.avatar);
      setState(() {
        _nameController.text = user?.displayName ?? '';
        _websiteController.text = user?.website ?? '';
        _emailController.text = user?.email ?? '';
        _phoneController.text = user?.phone ?? '';
      });
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User updatedUser = User(
        displayName: _nameController.text,
        website: _websiteController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );

      try {
        User userProfile = await userApi.updateProfile(updatedUser, _imageFile);
        print('Profile updated: ${userProfile.username}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated!')),
        );
      } catch (e) {
        print('Error Profile device: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating Profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Profile",
        onSidebarButtonPressed: () {},
        onBackButtonPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        },
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?.avatar != null && user!.avatar!.isNotEmpty)
                            ? NetworkImage('${Constants.apiUrl}${user!.avatar}')
                            : null,
                    child: (_imageFile == null &&
                            (user?.avatar == null || user!.avatar!.isEmpty))
                        ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _nameController,
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Name/Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _websiteController,
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Website'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Email'),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Phone'),
              ),
              const SizedBox(height: 48.0),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3DA9FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(0, 50),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
