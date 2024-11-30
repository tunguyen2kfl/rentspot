import 'package:flutter/material.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/pages/AdminUser/roomMgmt.dart';
import 'package:rent_spot/stores/userData.dart';

class CreateRoomView extends StatefulWidget {
  const CreateRoomView({Key? key}) : super(key: key);

  @override
  _CreateRoomViewState createState() => _CreateRoomViewState();
}

class _CreateRoomViewState extends State<CreateRoomView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController =
      TextEditingController(); // Controller cho Status
  bool _isOpen = false;
  List<Device> _availableDevices = [
    Device(
        id: '1',
        name: 'Print machine',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJFeEz4aT_A9B4YpiBAU9R3W8Ircf3OwABaw&s'),
    Device(
        id: '2',
        name: 'Projector',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJFeEz4aT_A9B4YpiBAU9R3W8Ircf3OwABaw&s'),
    Device(
        id: '3',
        name: 'Monitor',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJFeEz4aT_A9B4YpiBAU9R3W8Ircf3OwABaw&s'),
  ];
  List<Device> _selectedDevices = [];

  RoomApi roomApi = RoomApi(UserData());

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
    _roomNameController.dispose();
    _descriptionController.dispose();
    _statusController.dispose(); // Dispose status controller
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
                      backgroundImage: NetworkImage(device.imageUrl),
                    ),
                    title: Text(device.name),
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
      // Tạo một Room từ thông tin đã nhập
      String selectedDeviceIds = _selectedDevices.map((d) => d.id).join(',');
      Room newRoom = Room(
        name: _roomNameController.text,
        description: _descriptionController.text,
        isOpen: _isOpen,
        status: _statusController.text,
        devices: selectedDeviceIds,
      );

      try {
        // Gọi API để tạo Room
        Room createdRoom = await roomApi.create(newRoom);
        print('Room created: ${createdRoom.name}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room created!')),
        );

        // Chuyển hướng về màn hình RoomManagement
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainAdminScreen(initialPageIndex: 1)));
      } catch (e) {
        print('Error creating room: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating room: $e')),
        );
        // Hiển thị thông báo lỗi nếu cần
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Create Room",
        onSidebarButtonPressed: () {},
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        // Bọc trong SingleChildScrollView
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
                controller: _statusController, // Trường Status
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
                              backgroundImage: NetworkImage(device.imageUrl),
                            ),
                            label: Text(device.name),
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

class Device {
  final String id;
  final String name;
  final String imageUrl;

  Device({required this.id, required this.name, required this.imageUrl});
}
