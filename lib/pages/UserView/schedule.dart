import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/UpdateScheduleModal.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

String _formatTime(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

List<Map<String, dynamic>> schedules = [
  {
    'id': 1,
    'summary': 'Meeting with John',
    'date': DateTime.now(),
    'resourceId': 1,
    'status': 'confirmed',
    'color': '#007bff',
    'startTime': DateTime.now(),
    'endTime': DateTime.now().add(Duration(hours: 2)),
  },
  {
    'id': 2,
    'summary': 'Planning Session',
    'date': DateTime.now().add(Duration(days: 1)),
    'resourceId': 2,
    'status': 'pending',
    'color': '#28a745',
    'startTime': DateTime.now().add(Duration(days: 1, hours: 10)),
    'endTime': DateTime.now().add(Duration(days: 1, hours: 12)),
  },
];

class SchedulesView extends StatefulWidget {
  @override
  _SchedulesViewState createState() => _SchedulesViewState();
}

class _SchedulesViewState extends State<SchedulesView> {
  late _DataSource _events;

  @override
  void initState() {
    _events = _DataSource(_getAppointments(), _getCalendarResources());
    super.initState();
  }

  List<CalendarResource> _getCalendarResources() {
    return [
      CalendarResource(displayName: 'John', id: '1', color: Colors.white),
      CalendarResource(displayName: 'Smith', id: '2', color: Colors.white),
      CalendarResource(displayName: 'Smith2', id: '3', color: Colors.white),
    ];
  }

  List<Appointment> _getAppointments() {
    return schedules.map((schedule) {
      return Appointment(
        startTime: schedule['startTime'],
        endTime: schedule['endTime'],
        subject: schedule['summary'],
        color: Color(int.parse(schedule['color'].replaceAll('#', '0xff'))),
        resourceIds: [schedule['resourceId'].toString()],
        id: schedule['id'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    print(userData.role);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Schedule',
        onSidebarButtonPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 10),
        child: SfCalendar(
          view: CalendarView.timelineDay,
          dataSource: _events,
          headerStyle: const CalendarHeaderStyle(
              backgroundColor: Colors.white,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24)),
          todayHighlightColor: const Color(0xFF3DA9FC),
          showNavigationArrow: true,
          showDatePickerButton: true,
          showTodayButton: true,
          timeSlotViewSettings: const TimeSlotViewSettings(
              timeIntervalWidth: 200,
              timeInterval: Duration(minutes: 60),
              timeFormat: 'hh:mm a',
              timeTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38)),
          viewHeaderStyle: const ViewHeaderStyle(
            dayTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            dateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          resourceViewSettings: const ResourceViewSettings(
              showAvatar: false, visibleResourceCount: 5),
          resourceViewHeaderBuilder:
              (BuildContext context, ResourceViewHeaderDetails details) {
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
                        fontSize: 14),
                  ),
                ),
              ),
            );
          },
          appointmentBuilder:
              (BuildContext context, CalendarAppointmentDetails details) {
            final Appointment appointment = details.appointments.first;
            final schedule =
                schedules.firstWhere((s) => s['id'] == appointment.id);
            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: appointment.color
                    .withOpacity(schedule['status'] == 'pending' ? 0.5 : 1.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.subject,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4.0),
                  Text(
                    '${_formatTime(appointment.startTime)} - ${_formatTime(appointment.endTime)}',
                    style: const TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                ],
              ),
            );
          },
          onTap: (CalendarTapDetails details) {
            final Appointment appointment = details.appointments![0];
            _showBottomSheet(context, appointment);
          },
        ),
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

void _showBottomSheet(BuildContext context, Appointment appointment) {
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
                _showUpdateModal(context, appointment);
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

void _showUpdateModal(BuildContext context, Appointment appointment) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        child: UpdateScheduleModal(appointment: appointment),
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
