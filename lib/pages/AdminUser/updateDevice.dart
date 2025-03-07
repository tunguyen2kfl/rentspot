import 'package:flutter/material.dart';
import 'package:rent_spot/api/deviceApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/models/device.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateDeviceView extends StatefulWidget {
  final Device device;

  const UpdateDeviceView({Key? key, required this.device}) : super(key: key);

  @override
  _UpdateDeviceViewState createState() => _UpdateDeviceViewState();
}

class _UpdateDeviceViewState extends State<UpdateDeviceView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String baseUrl = Constants.apiUrl;
  File? _imageFile;

  DeviceApi deviceApi = DeviceApi(UserData());

  static const Color _textFieldBorderColor = Color(0xFF3DA9FC);

  @override
  void initState() {
    super.initState();

    _deviceNameController.text = widget.device.name ?? '';
    _descriptionController.text = widget.device.description ?? '';
  }

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
      Device updatedDevice = Device(
        id: widget.device.id,
        name: _deviceNameController.text,
        description: _descriptionController.text,
      );

      try {
        Device createdDevice =
            await deviceApi.update(updatedDevice, _imageFile);
        print('Device updated: ${createdDevice.name}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device updated!')),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainAdminScreen(initialPageIndex: 2)));
      } catch (e) {
        print('Error updating device: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating device: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Update Device",
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
                        ? NetworkImage('${baseUrl}${widget.device.image}')
                        : FileImage(_imageFile!),
                    child: _imageFile == null
                        ? Icon(Icons.camera_alt,
                            size: 50, color: _textFieldBorderColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _deviceNameController,
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Device Name'),
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
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Description'),
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
                  'Update',
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
