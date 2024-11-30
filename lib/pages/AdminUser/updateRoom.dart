import 'package:flutter/material.dart';
import 'package:rent_spot/api/deviceApi.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/models/device.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/stores/userData.dart';

class UpdateRoomView extends StatefulWidget {
  final Room room; // Nhận phòng cần cập nhật

  const UpdateRoomView({Key? key, required this.room}) : super(key: key);

  @override
  _UpdateRoomViewState createState() => _UpdateRoomViewState();
}

class _UpdateRoomViewState extends State<UpdateRoomView> {
  final String baseUrl = Constants.apiUrl;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  bool _isOpen = false;
  List<Device> _availableDevices = [];
  List<Device> _selectedDevices = [];

  RoomApi roomApi = RoomApi(UserData());
  DeviceApi deviceApi = DeviceApi(UserData());

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
  void initState() {
    super.initState();

    _roomNameController.text = widget.room.name ?? '';
    _descriptionController.text = widget.room.description ?? '';
    _statusController.text = widget.room.status ?? '';
    _isOpen = widget.room.isOpen ?? false;

    _fetchAvailableDevices();
  }

  Future<void> _fetchAvailableDevices() async {
    try {
      final devices = await deviceApi.getAll();
      setState(() {
        _availableDevices = devices;
        print('input');
        print(widget.room.devices?.split(','));
        print(devices.length);
        _selectedDevices = (widget.room.devices?.split(',') ?? []).map((id) {
          print(id);
          return devices.firstWhere((device) => device.id == int.parse(id),
              orElse: () => Device(id: null, name: 'Unknown', image: ''));
        }).toList();
      });
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _toggleDeviceSelection(Device device) {
    setState(() {
      if (_selectedDevices.contains(device)) {
        _selectedDevices.remove(device);
      } else {
        _selectedDevices.add(device);
      }
    });
  }

  void _showDeviceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _availableDevices.length,
                itemBuilder: (context, index) {
                  final device = _availableDevices[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          device.image != null && device.image!.isNotEmpty
                              ? NetworkImage('${baseUrl}${device.image}')
                              : AssetImage('assets/images/default_device.png')
                                  as ImageProvider,
                    ),
                    title: Text(device.name ?? ''),
                    trailing: Checkbox(
                      value: _selectedDevices.contains(device),
                      onChanged: (value) {
                        setState(() {
                          _toggleDeviceSelection(device);
                        });
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String selectedDeviceIds = _selectedDevices.map((d) => d.id).join(',');
      Room updatedRoom = Room(
        id: widget.room.id,
        name: _roomNameController.text,
        description: _descriptionController.text,
        isOpen: _isOpen,
        status: _statusController.text,
        devices: selectedDeviceIds,
      );

      print(widget.room.id);

      try {
        await roomApi.update(updatedRoom);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room updated!')),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainAdminScreen(initialPageIndex: 1)));
      } catch (e) {
        print('Error updating room: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Update Room",
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
              TextFormField(
                controller: _roomNameController,
                decoration:
                    customInputDecoration.copyWith(labelText: 'Room Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Is Open'),
                  Switch(
                    activeColor: _textFieldBorderColor,
                    value: _isOpen,
                    onChanged: (value) {
                      setState(() {
                        _isOpen = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _statusController,
                decoration: customInputDecoration.copyWith(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _showDeviceSelection,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: _textFieldBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Devices'),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        children: _selectedDevices.map((device) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundImage: device.image != null &&
                                      device.image!.isNotEmpty
                                  ? NetworkImage('${baseUrl}${device.image}')
                                  : AssetImage(
                                          'assets/images/default_device.png')
                                      as ImageProvider,
                            ),
                            label: Text(device.name ?? ''),
                            onDeleted: () {
                              _toggleDeviceSelection(device);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: _showDeviceSelection,
                        child: Text(
                          '+ Add Device',
                          style: TextStyle(color: _textFieldBorderColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    customInputDecoration.copyWith(labelText: 'Description'),
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
