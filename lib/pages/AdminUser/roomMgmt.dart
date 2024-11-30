import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/stores/userData.dart'; // Import UserData
import 'package:rent_spot/pages/AdminUser/updateRoom.dart'; // Import UpdateRoomView

class RoomManagementView extends StatefulWidget {
  @override
  _RoomManagementViewState createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<RoomManagementView> {
  late Future<List<Room>> _rooms;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      RoomApi roomApi = RoomApi(UserData());
      _rooms = roomApi.getAll();
    } catch (e) {
      print("Error fetching rooms: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRoom(int? roomId) async {
    try {
      RoomApi roomApi = RoomApi(UserData());
      await roomApi.delete(roomId);
      _fetchRooms();
    } catch (e) {
      print("Error deleting room: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting room: $e')));
    }
  }

  void _showDeleteConfirmation(int? roomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this room?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteRoom(roomId);
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
            : FutureBuilder<List<Room>>(
          future: _rooms,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No rooms available.'));
            }

            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name: ${room.name}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Text(
                              'Status: ${room.status}',
                              style: TextStyle(
                                color: (room.isOpen ?? false) ? Colors.green : Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Description: ${room.description}'),
                        const SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateRoomView(room: room),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(room.id);
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