import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/api/scheduleApi.dart';
import 'package:rent_spot/components/DateSlide.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/UserView/createSchedule.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/pages/UserView/schedule.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

// ... (các import khác và các hàm hỗ trợ)

class SchedulesMonthView extends StatefulWidget {
  @override
  _SchedulesMonthViewState createState() => _SchedulesMonthViewState();
}

final FlutterSecureStorage storage = FlutterSecureStorage();

class _SchedulesMonthViewState extends State<SchedulesMonthView> {
  String? _currentUserId;
  DateTime _selectedDate = DateTime.now();
  CalendarController _calendarController = CalendarController();
  late _DataSource _events;
  List<Room> _rooms = [];
  List<User> _users = [];
  List<Schedule> _schedules = [];
  bool isLoading = true;

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
    } catch (e) {
      print('Failed to load rooms: $e');
    }
    _updateLoadingState();
  }

  Future<void> _fetchUsers() async {
    final userApi = UserApi(UserData());
    try {
      _users = await userApi.getAllUserInBuilding(context);
    } catch (e) {
      print('Failed to load users: $e');
    }
    _updateLoadingState();
  }

  Future<void> _fetchSchedules() async {
    final scheduleApi = ScheduleApi(UserData());
    try {
      _schedules = await scheduleApi.getAll();
    } catch (e) {
      print('Failed to load schedules: $e');
    }
    _updateLoadingState();
  }

  void _updateLoadingState() {
    setState(() {
      isLoading = false;
      if (!isLoading) {
        _events = _DataSource(_getAppointments(), _getCalendarResources());
      }
    });
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
    return Scaffold(
      body: isLoading
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
              view: CalendarView.month,
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
                timeTextStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006bb3),
                ),
              ),
              resourceViewSettings: const ResourceViewSettings(
                showAvatar: false,
                visibleResourceCount: 4,
                size: 80,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  _showBottomMenu(context, details.date!);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomMenu(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_forward),
                title: const Text('Go To'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen(initialPageIndex: 0,initialDate: date,)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateSchedulePage(initialDate: date,)),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }
}