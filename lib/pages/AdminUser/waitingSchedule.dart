import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_spot/models/Schedule.dart';

class WaitingScheduleView extends StatelessWidget {
  final List<Schedule> schedules = [
    Schedule(
      id: 1,
      summary: 'Meeting with John',
      date: DateTime.now(),
      roomId: 1,
      status: 'confirmed',
      color: '#007bff', // Blue color
      startTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
      endTime: TimeOfDay(hour: DateTime.now().add(Duration(hours: 2)).hour, minute: DateTime.now().add(Duration(hours: 2)).minute),
      attendees: "a@gmail.com",
    ),
    Schedule(
      id: 2,
      summary: 'Team Building',
      date: DateTime.now(),
      roomId: 2,
      status: 'pending',
      color: '#28a745', // Green color
      startTime: TimeOfDay(hour: DateTime.now().add(Duration(hours: 1)).hour, minute: DateTime.now().add(Duration(hours: 1)).minute),
      endTime: TimeOfDay(hour: DateTime.now().add(Duration(hours: 3)).hour, minute: DateTime.now().add(Duration(hours: 3)).minute),
      attendees: "b@gmail.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary: ${schedule.summary}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Room: P.${schedule.roomId}'),
                    const SizedBox(height: 4),
                    Text(
                      'Time: ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.startTime!.hour, schedule.startTime!.minute))} - ${DateFormat.jm().format(DateTime(0, 0, 0, schedule.endTime!.hour, schedule.endTime!.minute))} | ${DateFormat.yMd().format(schedule.date!)}',
                    ),
                    const SizedBox(height: 4),
                    Text('Organizer: ${schedule.attendees}', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month, color: Colors.blue),
                          onPressed: () {
                            // Logic to view details
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            // Logic to approve schedule
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            // Logic to reject schedule
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