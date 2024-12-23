import 'package:flutter/material.dart';
import 'package:rent_spot/api/deviceApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/device.dart';
import 'package:rent_spot/stores/userData.dart';

class RoomDetailModal extends StatefulWidget {
  final Room room;

  const RoomDetailModal({Key? key, required this.room}) : super(key: key);

  @override
  _RoomDetailModalState createState() => _RoomDetailModalState();
}

class _RoomDetailModalState extends State<RoomDetailModal> {
  final String baseUrl = Constants.apiUrl;
  List<Device> _availableDevices = [];
  List<Device> _selectedDevices = [];

  DeviceApi deviceApi = DeviceApi(UserData());

  @override
  void initState() {
    super.initState();
    _fetchAvailableDevices();
  }

  Future<void> _fetchAvailableDevices() async {
    try {
      final devices = await deviceApi.getAll();
      setState(() {
        _availableDevices = devices;

        _selectedDevices = (widget.room.devices?.split(',') ?? []).map((id) {
          return devices.firstWhere(
                (device) => device.id == int.parse(id),
            orElse: () => Device(id: -1, name: 'Unknown', image: ''),
          );
        }).toList();

        _selectedDevices = _selectedDevices.where((device) => device.id != -1).toList();
      });
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Đóng modal khi nhấn ra ngoài
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16.0),
              _buildDetailRow(Icons.home, 'Room Name', widget.room.name ?? 'N/A'),
              const SizedBox(height: 8.0),
              _buildDetailRow(Icons.open_in_new, 'Is Open', widget.room.isOpen == true ? 'Yes' : 'No'),
              const SizedBox(height: 8.0),
              _buildDetailRow(Icons.info, 'Status', widget.room.status ?? 'N/A'),
              const SizedBox(height: 8.0),
              _buildDevicesRow(_selectedDevices),
              const SizedBox(height: 8.0),
              _buildDetailRow(Icons.description, 'Description', widget.room.description ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Room Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Đóng modal
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF3DA9FC)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesRow(List<Device> devices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Devices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: devices.map((device) {
            return Chip(
              avatar: CircleAvatar(
                backgroundImage: device.image != null && device.image!.isNotEmpty
                    ? NetworkImage('${baseUrl}${device.image}')
                    : AssetImage('assets/images/default_device.png') as ImageProvider,
              ),
              label: Text(device.name ?? 'Unknown Device'),
            );
          }).toList(),
        ),
      ],
    );
  }
}