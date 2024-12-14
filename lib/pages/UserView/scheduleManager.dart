import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/api/scheduleApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/UpdateScheduleModal.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';

class MySchedulesView extends StatefulWidget {
  @override
  _MySchedulesViewState createState() => _MySchedulesViewState();
}

class _MySchedulesViewState extends State<MySchedulesView> {
  late ScheduleApi scheduleApi;
  late UserApi userApi;
  late Future<List<Schedule>> _schedulesFuture;
  List<User> _users = [];
  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    final userData = UserData();
    scheduleApi = ScheduleApi(userData);
    userApi = UserApi(userData);
    _fetchUsers();
    _fetchRooms();
    _loadMySchedules();
  }

  void _loadMySchedules() {
    setState(() {
      _schedulesFuture = scheduleApi.getMySchedules();
    });
  }

  void _fetchUsers() async {
    try {
      _users = await userApi.getAllUserInBuilding(context);
      setState(() {});
    } catch (e) {
      print('Failed to load users: $e');
    }
  }

  Future<void> _fetchRooms() async {
    final roomApi = RoomApi(UserData());
    try {
      _rooms = await roomApi.getAll();
      setState(() {});
    } catch (e) {
      print('Failed to load rooms: $e');
    }
  }

  Future<void> _updateSchedule(Schedule schedule) async {
    try {
      Schedule updatedSchedule = await scheduleApi.update(schedule);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule updated: ${updatedSchedule.summary}')),
      );
      _loadMySchedules();
    } catch (e) {
      print('Error updating schedule: $e');
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await scheduleApi.delete(int.parse(scheduleId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule deleted')),
      );
      _loadMySchedules();
    } catch (e) {
      print('Error deleting schedule: $e');
    }
  }

  String _getRoomName(int? roomId) {
    final room = _rooms.firstWhere((room) => room.id == roomId,
        orElse: () => Room(name: 'Unknown Room'));
    return room.name ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Schedule>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No schedules available.'));
            }

            final schedules = snapshot.data!;

            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final organizer = _users.firstWhere(
                  (user) => user.id == schedule.organizer,
                  orElse: () => User(displayName: 'Unknown'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary: ${schedule.summary}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Room: ${_getRoomName(schedule.roomId)}'), // Hiển thị tên phòng
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.startTime!.hour, schedule.startTime!.minute))} - ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.endTime!.hour, schedule.endTime!.minute))} | ${DateFormat.yMd().format(schedule.date!)}',
                        ),
                        const SizedBox(height: 4),
                        Text('Organizer: ${organizer.displayName}',
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Status: ',
                            ),
                            Text(
                              getStatusText(schedule.status ?? ""),
                              style: TextStyle(
                                color: _getStatusColor(schedule.status ?? ""),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showUpdateModal(
                                    context, schedule, _users, _rooms);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteSchedule(schedule.id.toString());
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

void _showUpdateModal(BuildContext context, Schedule schedule, List<User> users,
    List<Room> rooms) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        child:
            UpdateScheduleModal(schedule: schedule, users: users, rooms: rooms),
      );
    },
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'cancel':
      return Colors.red;
    default:
      return Colors.black;
  }
}

String getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return ' Confirmed';
    case 'pending':
      return ' Pending';
    case 'cancel':
      return ' Cancel';
    default:
      return ' Unknow';
  }
}
