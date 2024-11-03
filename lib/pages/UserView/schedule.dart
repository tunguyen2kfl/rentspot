import 'package:flutter/material.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math';
import 'package:intl/intl.dart'; // Import for date formatting

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
    'color': '#007bff', // Blue color
    'startTime': DateTime.now(),
    'endTime': DateTime.now().add(Duration(hours: 2)),
  },
  {
    'id': 2,
    'summary': 'Planning Session',
    'date': DateTime.now().add(Duration(days: 1)),
    'resourceId': 2,
    'status': 'pending',
    'color': '#28a745', // Green color
    'startTime': DateTime.now().add(Duration(days: 1, hours: 10)),
    'endTime': DateTime.now().add(Duration(days: 1, hours: 12)),
  },
  // Add more schedules as needed
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
    return <CalendarResource>[
      CalendarResource(displayName: 'John', id: '1', color: Colors.white),
      CalendarResource(displayName: 'Smith', id: '2', color: Colors.white),
      CalendarResource(displayName: 'Smith2', id: '3', color: Colors.white),
    ];
  }

  List<Appointment> _getAppointments() {
    List<Appointment> calendarSchedules = schedules.map((schedule) {
      // Assuming schedule['date'] is a DateTime and schedule['startTime'], schedule['endTime'] are TimeOfDay

      return Appointment(
        startTime: schedule['startTime'],
        endTime: schedule['endTime'],
        subject: schedule['summary'],
        color: Color(int.parse(schedule['color'].replaceAll('#', '0xff'))),
        resourceIds: [schedule['resourceId'].toString()],
        id: schedule['id'],
      );
    }).toList();
    return calendarSchedules;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Schedule',
        onBackButtonPressed: () {
          Navigator.pop(context); // Handle back button press
        },
        onSidebarButtonPressed: () {
          // Handle sidebar button press (e.g., open a drawer)
        },
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 10), // Add bottom padding
        child: SfCalendar(
          view: CalendarView.timelineDay,
          dataSource: _events,
          headerStyle: const CalendarHeaderStyle(
              backgroundColor: Colors.white,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24)
          ),
          todayHighlightColor: const Color(0xFF3DA9FC),
          showNavigationArrow: true,
          showDatePickerButton: true,
          showTodayButton: true,
          timeSlotViewSettings: const TimeSlotViewSettings(
              timeIntervalWidth: 200,
              timeInterval: Duration(minutes: 60),
              timeFormat: 'hh:mm a',
              timeTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38),
          ),
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
                  right: BorderSide(
                      color: Colors.grey, width: 0.5), // Right border
                  bottom: BorderSide(
                      color: Colors.grey, width: 0.5), // Bottom border
                ),
                color: resource.color, // Set header background color
              ),
              child: Center(
                // Center the content
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
          appointmentBuilder:
              (BuildContext context, CalendarAppointmentDetails details) {
            final Appointment appointment = details.appointments.first;
            // Find the corresponding schedule based on the appointment ID
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
                  Text(
                    // schedule['summary'], // Use summary from schedule data
                    appointment.subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
            if (details.targetElement == CalendarElement.appointment) {
              final Appointment appointment = details.appointments![0];
              print('Event clicked: ${appointment.id}');
            }
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
