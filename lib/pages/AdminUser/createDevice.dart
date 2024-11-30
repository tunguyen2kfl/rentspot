import 'package:flutter/material.dart';
import 'package:rent_spot/api/deviceApi.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/models/device.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateDeviceView extends StatefulWidget {
  const CreateDeviceView({Key? key}) : super(key: key);

  @override
  _CreateDeviceViewState createState() => _CreateDeviceViewState();
}

class _CreateDeviceViewState extends State<CreateDeviceView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  DeviceApi deviceApi = DeviceApi(UserData());

  // Style input decoration
  static const double _textFieldBorderRadius = 10;
  static const Color _textFieldBorderColor = Color(0xFF3DA9FC);
  static const double _textFieldBorderWidth = 2.0;

  final InputDecoration customInputDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
      borderSide: BorderSide(
          color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
      borderSide: BorderSide(
          color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
    ),
    labelStyle: TextStyle(color: Colors.grey),
  );

  @override
  void dispose() {
    _deviceNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Device newDevice = Device(
        name: _deviceNameController.text,
        description: _descriptionController.text,
      );

      try {
        // Gọi API để tạo Device
        Device createdDevice = await deviceApi.create(newDevice, _imageFile);
        print('Device created: ${createdDevice.name}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device created!')),
        );

        // Chuyển hướng về màn hình chính
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainAdminScreen(initialPageIndex: 2)));
      } catch (e) {
        print('Error creating device: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating device: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Create Device",
        onSidebarButtonPressed: () {},
        onBackButtonPressed: () {
          Navigator.pop(context);
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
                    radius: 50,
                    backgroundImage: _imageFile == null
                        ? null
                        : FileImage(_imageFile!),
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt, size: 50, color: _textFieldBorderColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _deviceNameController,
                decoration: customInputDecoration.copyWith(labelText: 'Device Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: customInputDecoration.copyWith(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
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
}