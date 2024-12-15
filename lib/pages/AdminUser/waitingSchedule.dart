import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_spot/api/scheduleApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';

class WaitingScheduleView extends StatefulWidget {
  @override
  _WaitingScheduleViewState createState() => _WaitingScheduleViewState();
}

class _WaitingScheduleViewState extends State<WaitingScheduleView> {
  late ScheduleApi scheduleApi;
  late UserApi userApi;
  late Future<List<Schedule>> _schedulesFuture;
  late Future<List<User>> _usersFuture;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    final userData = UserData();
    scheduleApi = ScheduleApi(userData);
    userApi = UserApi(userData);
    _fetchUsers();
    _loadWaitingSchedules();
  }

  void _loadWaitingSchedules() {
    setState(() {
      _schedulesFuture = scheduleApi.getWaitingSchedules();
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

  Future<void> _passSchedule(String scheduleId) async {
    try {
      await scheduleApi.passWaitingSchedules(scheduleId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Confirm schedule')));
      _loadWaitingSchedules();
    } catch (e) {
      // Handle error
      print('Error passing schedule: $e');
    }
  }

  Future<void> _cancelSchedule(String scheduleId) async {
    try {
      await scheduleApi.cancelWaitingSchedules(scheduleId);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cancel schedule')));
      _loadWaitingSchedules();
    } catch (e) {
      // Handle error
      print('Error cancelling schedule: $e');
    }
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
              return Center(child: Text('No waiting schedules available.'));
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
                        Text('Room: P.${schedule.roomId}'),
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.startTime!.hour, schedule.startTime!.minute))} - ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.endTime!.hour, schedule.endTime!.minute))} | ${DateFormat.yMd().format(schedule.date!)}',
                        ),
                        const SizedBox(height: 4),
                        Text('Organizer: ${organizer.displayName}',
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calendar_month,
                                  color: Colors.blue),
                              onPressed: () {
                                // Logic to view details
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _passSchedule(schedule.id.toString());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                _cancelSchedule(schedule.id.toString());
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
