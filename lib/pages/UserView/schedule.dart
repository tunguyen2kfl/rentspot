import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/api/scheduleApi.dart';
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
  final formattedTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return DateFormat('hh:mm a').format(formattedTime);
}

class SchedulesView extends StatefulWidget {
  @override
  _SchedulesViewState createState() => _SchedulesViewState();
}

final FlutterSecureStorage storage = FlutterSecureStorage();

class _SchedulesViewState extends State<SchedulesView> {
  String? _currentUserId;
  DateTime _selectedDate = DateTime.now();
  CalendarController _calendarController = CalendarController();
  late _DataSource _events;
  List<Room> _rooms = [];
  List<User> _users = [];
  List<Schedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchRooms();
    _fetchUsers();
    _fetchSchedules();
  }

  Future<void> _fetchCurrentUserId() async {
    _currentUserId = await storage.read(key: 'id');
    setState(() {});
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
      setState(() {});
    } catch (e) {
      print('Failed to load users: $e');
    }
  }

  Future<void> _fetchSchedules() async {
    final scheduleApi = ScheduleApi(UserData());
    try {
      _schedules = await scheduleApi.getAll();
      print(_schedules.length);
      _events = _DataSource(_getAppointments(), _getCalendarResources());
      setState(() {}); // Gọi setState sau khi cập nhật tất cả
    } catch (e) {
      print('Failed to load schedules: $e');
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
    if (_schedules.isEmpty) {
      return [];
    }
    return _schedules.map((schedule) {
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
        color: schedule.status == "cancel"
            ? Colors.red
            : Color(int.parse(schedule.color!.replaceAll('#', '0xff'))),
        resourceIds: [schedule.roomId.toString()],
        id: schedule.id,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Scaffold(
      body: _rooms.isEmpty || _schedules.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                DateSlider(
                  selectedDate: _selectedDate,
                  onDateSelected: (selectedDate) {
                    _calendarController.displayDate = selectedDate;
                    setState(() {
                      _selectedDate = selectedDate;
                    });
                  },
                ),
                Expanded(
                  child: SfCalendar(
                    view: CalendarView.timelineDay,
                    onViewChanged: (data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_selectedDate != data.visibleDates[0]) {
                          setState(() {
                            _selectedDate = data.visibleDates[0];
                          });
                        }
                      });
                    },
                    dataSource: _events,
                    initialDisplayDate: DateTime.now(),
                    controller: _calendarController,
                    headerHeight: 50,
                    headerStyle: const CalendarHeaderStyle(
                      backgroundColor: Colors.white,
                      textAlign: TextAlign.left,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                    todayHighlightColor: const Color(0xFF3DA9FC),
                    showDatePickerButton: true,
                    showTodayButton: true,
                    cellBorderColor: Colors.blue,
                    timeSlotViewSettings: const TimeSlotViewSettings(
                      timeIntervalWidth: 200,
                      timeInterval: Duration(minutes: 60),
                      timeFormat: 'hh:mm a',
                      // timeRulerSize: 40,
                      timeTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color:  Color(0xFF006bb3),
                      ),
                    ),
                    viewHeaderStyle: const ViewHeaderStyle(
                      dayTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      dateTextStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    resourceViewSettings: const ResourceViewSettings(
                        showAvatar: false, visibleResourceCount: 4, size: 80),
                    resourceViewHeaderBuilder: (BuildContext context,
                        ResourceViewHeaderDetails details) {
                      final CalendarResource resource = details.resource;
                      return DecoratedBox(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 1),
                          ),
                          color: Color(0xFF006bb3),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              resource.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    appointmentBuilder: (BuildContext context,
                        CalendarAppointmentDetails details) {
                      final Appointment appointment =
                          details.appointments.first;
                      final schedule =
                          _schedules.firstWhere((s) => s.id == appointment.id);
                      final organizer =
                          _users.firstWhere((u) => u.id == schedule.organizer);
                      String cancelString =
                          schedule.status == 'cancel' ? " [CANCEL]" : "";
                      return Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: appointment.color
                              .withOpacity(schedule.status == 'pending'
                                  ? 0.5
                                  : schedule.status == 'cancel'
                                      ? 0.8
                                      : 1.0),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.subject + cancelString,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            if (schedule.startTime != null &&
                                schedule.endTime != null)
                              Text(
                                '${_formatTime(schedule.startTime!)} - ${_formatTime(schedule.endTime!)}',
                                style: const TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                              ),
                            if (organizer != null)
                              Text(
                                '${organizer.displayName}',
                                style: const TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                              ),
                          ],
                        ),
                      );
                    },
                    onTap: (CalendarTapDetails details) {
                      if (details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        final Appointment appointment =
                            details.appointments![0];
                        final schedule = _schedules
                            .firstWhere((s) => s.id == appointment.id);

                        if (schedule.organizer.toString() == _currentUserId) {
                          _showBottomSheet(context, appointment, _users,
                              _schedules, _rooms, _fetchSchedules);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'You are not authorized to modify this schedule.')),
                          );
                        }
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

void _showBottomSheet(
    BuildContext context,
    Appointment appointment,
    List<User> users,
    List<Schedule> schedules,
    List<Room> rooms,
    Future<void> Function() fetchSchedules) {
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
                _showUpdateModal(context, appointment, users, schedules, rooms);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteModal(
                    context, appointment, schedules, fetchSchedules);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showUpdateModal(BuildContext context, Appointment appointment,
    List<User> users, List<Schedule> schedules, List<Room> rooms) {
  final schedule = schedules.firstWhere((s) => s.id == appointment.id);
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

void _showDeleteModal(BuildContext context, Appointment appointment,
    List<Schedule> schedules, Future<void> Function() fetchSchedules) {
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
            onPressed: () async {
              final schedule =
                  schedules.firstWhere((s) => s.id == appointment.id);
              final scheduleApi = ScheduleApi(UserData());
              try {
                await scheduleApi.delete(schedule.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Schedule deleted successfully!')),
                );
                Navigator.pop(context);
                await fetchSchedules();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete schedule: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
