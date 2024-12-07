import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/DateSlide.dart';
import 'package:rent_spot/components/UpdateScheduleModal.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

String _formatTime(TimeOfDay time) {
  final now = DateTime.now();
  final formattedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('hh:mm a').format(formattedTime);
}

List<Schedule> mockSchedules = [
  Schedule(
    id: 1,
    summary: 'Meeting with John',
    organizer: 14,
    date: DateTime.now(),
    roomId: 1,
    status: 'confirmed',
    color: '#007bff',
    startTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    endTime: TimeOfDay(hour: DateTime.now().add(Duration(hours: 2)).hour, minute: DateTime.now().add(Duration(hours: 2)).minute),
    attendees: "a@gmail.com,c@gmail.com",
  ),
  Schedule(
    id: 2,
    organizer: 1,
    summary: 'Planning Session',
    date: DateTime.now().add(Duration(days: 1)),
    roomId: 2,
    status: 'pending',
    color: '#007bff',
    startTime: TimeOfDay(hour: DateTime.now().add(Duration(days: 1, hours: 10)).hour, minute: DateTime.now().add(Duration(days: 1, hours: 10)).minute),
    endTime: TimeOfDay(hour: DateTime.now().add(Duration(days: 1, hours: 12)).hour, minute: DateTime.now().add(Duration(days: 1, hours: 12)).minute),
    attendees: "b@gmail.com",
  ),
];

class SchedulesView extends StatefulWidget {
  @override
  _SchedulesViewState createState() => _SchedulesViewState();
}

class _SchedulesViewState extends State<SchedulesView> {
  DateTime _selectedDate = DateTime.now();
  CalendarController _calendarController = CalendarController();
  late _DataSource _events;
  List<Room> _rooms = [];
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _fetchUsers();
  }

  Future<void> _fetchRooms() async {
    final roomApi = RoomApi(UserData());
    try {
      _rooms = await roomApi.getAll();
      _events = _DataSource(_getAppointments(), _getCalendarResources());
      setState(() {});
    } catch (e) {
      print('Failed to load rooms: $e');
    }
  }

  Future<void> _fetchUsers() async {
    final userApi = UserApi(UserData());
    try {
      _users = await userApi.getAllUserInBuilding(context);
      print(_users.length);
      setState(() {});
    } catch (e) {
      print('Failed to load rooms: $e');
    }
  }

  List<CalendarResource> _getCalendarResources() {
    return _rooms.map((room) {
      return CalendarResource(
        displayName: room.name ?? 'Unknown Room',
        id: room.id.toString(),
        color: Colors.white,
      );
    }).toList();
  }

  List<Appointment> _getAppointments() {
    return mockSchedules.map((schedule) {
      return Appointment(
        startTime: DateTime(
          schedule.date!.year,
          schedule.date!.month,
          schedule.date!.day,
          schedule.startTime!.hour,
          schedule.startTime!.minute,
        ),
        endTime: DateTime(
          schedule.date!.year,
          schedule.date!.month,
          schedule.date!.day,
          schedule.endTime!.hour,
          schedule.endTime!.minute,
        ),
        subject: schedule.summary ?? "",
        color: Color(int.parse(schedule.color!.replaceAll('#', '0xff'))),
        resourceIds: [schedule.roomId.toString()],
        id: schedule.id,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    print(userData.role);

    return Scaffold(
      body: _rooms.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          DateSlider(
            onDateSelected: (selectedDate) {
              print(selectedDate);
              _calendarController.displayDate = selectedDate;
              setState(() {
                _selectedDate = selectedDate;
              });
            },
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.timelineDay,
              dataSource: _events,
              headerHeight: 80,
              initialDisplayDate: _selectedDate,
              controller: _calendarController,
              headerStyle: const CalendarHeaderStyle(
                backgroundColor: Colors.white,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              todayHighlightColor: const Color(0xFF3DA9FC),
              showDatePickerButton: true,
              showTodayButton: true,
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeIntervalWidth: 200,
                timeInterval: Duration(minutes: 60),
                timeFormat: 'hh:mm a',
                timeTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
              ),
              viewHeaderStyle: const ViewHeaderStyle(
                dayTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                dateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              resourceViewSettings: const ResourceViewSettings(
                showAvatar: false,
                visibleResourceCount: 5,
              ),
              resourceViewHeaderBuilder: (BuildContext context, ResourceViewHeaderDetails details) {
                final CalendarResource resource = details.resource;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: const Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                      right: BorderSide(color: Colors.grey, width: 0.5),
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    color: resource.color,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        resource.displayName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
              appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                final Appointment appointment = details.appointments.first;
                final schedule = mockSchedules.firstWhere((s) => s.id == appointment.id);
                final organizer = _users.firstWhere((u) => u.id == schedule.organizer);
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: appointment.color.withOpacity(schedule.status == 'pending' ? 0.5 : 1.0),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (schedule.startTime != null && schedule.endTime != null)
                        Text(
                          '${_formatTime(schedule.startTime!)} - ${_formatTime(schedule.endTime!)}',
                          style: const TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      if(organizer != null)
                        Text(
                          '${organizer.displayName}',
                          style: const TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null && details.appointments!.isNotEmpty) {
                  final Appointment appointment = details.appointments![0];
                  _showBottomSheet(context, appointment, _users);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }
}

void _showBottomSheet(BuildContext context, Appointment appointment, List<User> users) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Update Schedule'),
              onTap: () {
                Navigator.pop(context);
                _showUpdateModal(context, appointment, users);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteModal(context, appointment);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showUpdateModal(BuildContext context, Appointment appointment, List<User> users) {
  final schedule = mockSchedules.firstWhere((s) => s.id == appointment.id);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        child: UpdateScheduleModal(schedule: schedule, users: users),
      );
    },
  );
}

void _showDeleteModal(BuildContext context, Appointment appointment) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}