import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:rent_spot/api/scheduleApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/stores/userData.dart';

class UpdateScheduleModal extends StatefulWidget {
  final Schedule schedule;
  final List<User> users;
  final List<Room> rooms;

  const UpdateScheduleModal({
    Key? key,
    required this.schedule,
    required this.users,
    required this.rooms,
  }) : super(key: key);

  @override
  _UpdateScheduleModalState createState() => _UpdateScheduleModalState();
}

class _UpdateScheduleModalState extends State<UpdateScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _summaryController;
  late List<String> _attendees;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColor;
  late TextEditingController _descriptionController;
  late TextEditingController _attendeeController;
  late DateTime _selectedDate;
  String? _selectedOrganizerId;
  String? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.schedule.summary);
    _attendees = widget.schedule.attendees
            ?.split(',')
            .where((attendee) => attendee.isNotEmpty)
            .toList() ??
        [];
    _attendeeController = TextEditingController();
    _startTime = widget.schedule.startTime ?? TimeOfDay.now();
    _endTime = widget.schedule.endTime ?? TimeOfDay.now();
    _selectedColor = int.parse(
        widget.schedule.color?.replaceFirst('#', '0xff') ?? '0xffffffff');
    _selectedDate = widget.schedule.date ?? DateTime.now();
    _descriptionController =
        TextEditingController(text: widget.schedule.description);
    _selectedOrganizerId = widget.schedule.organizer?.toString();
    _selectedRoomId = widget.schedule.roomId?.toString();
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      final String summary = _summaryController.text;
      final String organizer = _selectedOrganizerId ?? '1';
      final String selectedRoomId = _selectedRoomId ?? '1';
      final List<String> attendees = _attendees;
      final TimeOfDay startTime = _startTime;
      final TimeOfDay endTime = _endTime;
      final String description = _descriptionController.text;
      // final DateTime selectedDate = _selectedDate;
      final DateTime selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      String colorString = '#${_selectedColor.toRadixString(16).substring(2)}';

      Schedule updatedSchedule = Schedule(
        id: widget.schedule.id,
        summary: summary,
        organizer: int.parse(organizer),
        attendees: attendees.join(','),
        startTime: startTime,
        endTime: endTime,
        color: colorString,
        description: description,
        date: selectedDate,
        roomId: int.parse(selectedRoomId),
      );

      try {
        await ScheduleApi(UserData()).update(updatedSchedule);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update schedule: $e')),
        );
      }
    }
  }

  List<Widget> _buildAttendeesSection() {
    return [
      TextFormField(
        controller: _attendeeController,
        decoration:
            Constants.customInputDecoration.copyWith(hintText: 'Enter email'),
      ),
      const SizedBox(height: 10.0),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC))),
        onPressed: () {
          if (RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(_attendeeController.text)) {
            setState(() {
              _attendees.add(_attendeeController.text);
              _attendeeController.clear();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _attendees.map((attendee) {
          return Chip(
            label: Text(attendee),
            onDeleted: () {
              setState(() {
                _attendees.remove(attendee);
              });
            },
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildTimePickers() {
    return [
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    if (pickedTime.hour > _endTime.hour ||
                        (pickedTime.hour == _endTime.hour &&
                            pickedTime.minute >= _endTime.minute)) {
                      _endTime =
                          TimeOfDay(hour: pickedTime.hour + 1, minute: 0);
                    }
                    _startTime = pickedTime;
                  });
                }
              },
              child: InputDecorator(
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'Start Time'),
                child: Text(_startTime.format(context)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (pickedTime != null) {
                  setState(() {
                    if (pickedTime.hour < _startTime.hour ||
                        (pickedTime.hour == _startTime.hour &&
                            pickedTime.minute <= _startTime.minute)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('End Time must be after Start Time')),
                      );
                    } else {
                      _endTime = pickedTime;
                    }
                  });
                }
              },
              child: InputDecorator(
                decoration: Constants.customInputDecoration
                    .copyWith(labelText: 'End Time'),
                child: Text(_endTime.format(context)),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildColorPicker() {
    return [
      const Text('Color'),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select Color'),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    pickerColor: Color(_selectedColor),
                    onColorChanged: (color) {
                      setState(() {
                        _selectedColor = color.value;
                      });
                    },
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(_selectedColor),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Schedule',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500)),
          leading: IconButton(
            icon: const Icon(
              Icons.highlight_off,
              size: 24,
              color: Color(0xFF3DA9FC),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC)),
              ),
              onPressed: submit,
              child: const Text(
                'Update',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _summaryController,
                      decoration: Constants.customInputDecoration
                          .copyWith(labelText: 'Schedule Summary'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a summary';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedOrganizerId,
                      decoration: Constants.customInputDecoration
                          .copyWith(labelText: 'Organizer'),
                      items: widget.users.map((User user) {
                        return DropdownMenuItem<String>(
                          value: user.id.toString(),
                          child: Text(user.displayName ?? ""),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrganizerId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an organizer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: _selectedRoomId,
                      decoration: Constants.customInputDecoration
                          .copyWith(labelText: 'Room'),
                      items: widget.rooms.map((Room room) {
                        return DropdownMenuItem<String>(
                          value: room.id.toString(),
                          child: Text(room.name ?? ""),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a room';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Attendees', textAlign: TextAlign.left),
                    ..._buildAttendeesSection(),
                    const SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2025),
                        );
                        if (pickedDate != null && pickedDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: Constants.customInputDecoration
                            .copyWith(labelText: 'Date'),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ..._buildTimePickers(),
                    const SizedBox(height: 16.0),
                    ..._buildColorPicker(),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: Constants.customInputDecoration
                          .copyWith(labelText: 'Description'),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
