import 'package:flutter/material.dart';

class Room {
  final String name;
  final bool isOpen;
  final String status;
  final List<String> devices;
  final String description;

  Room({
    required this.name,
    required this.isOpen,
    required this.status,
    required this.devices,
    required this.description,
  });
}

class RoomManagementView extends StatelessWidget {
  final List<Room> rooms = [
    Room(
      name: 'P.102',
      isOpen: true,
      status: 'Active',
      devices: ['Projector', 'Whiteboard'],
      description: 'Conference Room',
    ),
    Room(
      name: 'P.103',
      isOpen: false,
      status: 'Maintenance',
      devices: ['TV', 'Sound System'],
      description: 'Meeting Room',
    ),
    Room(
      name: 'P.104',
      isOpen: true,
      status: 'Active',
      devices: ['Computer', 'Teleconferencing'],
      description: 'Training Room',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Logic for adding a new room
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${room.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${room.status}',
                      style: TextStyle(
                        color: room.isOpen ? Colors.green : Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Description: ${room.description}'),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Logic to edit room
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Logic to delete room
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}