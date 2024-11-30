import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rent_spot/api/deviceApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/device.dart';
import 'package:rent_spot/stores/userData.dart'; // Import UserData
// Import UpdateDeviceView

class DeviceManagementView extends StatefulWidget {
  @override
  _DeviceManagementViewState createState() => _DeviceManagementViewState();
}

class _DeviceManagementViewState extends State<DeviceManagementView> {
  late Future<List<Device>> _devices;
  bool _isLoading = true;
  final String baseUrl = Constants.apiUrl;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    try {
      DeviceApi deviceApi = DeviceApi(UserData());
      _devices = deviceApi.getAll();
    } catch (e) {
      print("Error fetching devices: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDevice(int? deviceId) async {
    try {
      DeviceApi deviceApi = DeviceApi(UserData());
      await deviceApi.delete(deviceId);
      _fetchDevices();
    } catch (e) {
      print("Error deleting device: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting device: $e')));
    }
  }

  void _showDeleteConfirmation(int? deviceId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this device?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteDevice(deviceId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Hiển thị loading
            : FutureBuilder<List<Device>>(
          future: _devices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No devices available.'));
            }

            final devices = snapshot.data!;
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Hình ảnh thiết bị
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: device.image != null && device.image!.isNotEmpty
                              ? NetworkImage('${baseUrl}${device.image}')
                              : AssetImage('assets/images/default_device.png') as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${device.name}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const SizedBox(height: 8),
                              Text('Description: ${device.description}'),
                            ],
                          ),
                        ),
                        // Nút chỉnh sửa và xóa
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => UpdateDeviceView(device: device),
                                //   ),
                                // );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(device.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}