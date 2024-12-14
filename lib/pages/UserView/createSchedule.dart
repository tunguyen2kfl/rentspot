import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:rent_spot/api/scheduleApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/api/roomApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/Schedule.dart';
import 'package:rent_spot/models/room.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/stores/userData.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateSchedulePage extends StatefulWidget {
  @override
  _CreateSchedulePageState createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
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
  List<User> _users = [];
  List<Room> _rooms = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController();
    _attendees = [];
    _attendeeController = TextEditingController();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now();
    _selectedColor = 0xFF3DA9FC;
    _selectedDate = DateTime.now();
    _descriptionController = TextEditingController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _users = await UserApi(UserData()).getAllUserInBuilding(context);
      _rooms = await RoomApi(UserData()).getAll();

      String? userId = await _storage.read(key: 'id');
      setState(() {
        _selectedOrganizerId = userId;
        if (_rooms.isNotEmpty) {
          _selectedRoomId = _rooms.first.id.toString();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      final String summary = _summaryController.text;
      final String organizer = _selectedOrganizerId ?? '';
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

      Schedule newSchedule = Schedule(
        summary: summary,
        organizer: int.parse(organizer),
        attendees: attendees.join(','),
        startTime: startTime,
        endTime: endTime,
        color: colorString,
        description: description,
        date: selectedDate,
        roomId: int.parse(_selectedRoomId ?? '1'),
      );

      try {
        await ScheduleApi(UserData()).create(newSchedule);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create schedule: $e')),
        );
      }
    }
  }

  List<Widget> _buildAttendeesSection() {
    return [
      TextFormField(
        controller: _attendeeController,
        decoration: Constants.customInputDecoration.copyWith(hintText: 'Enter email'),
      ),
      const SizedBox(height: 10.0),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC))),
        onPressed: () {
          if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
                        (pickedTime.hour == _endTime.hour && pickedTime.minute >= _endTime.minute)) {
                      // Nếu StartTime lớn hơn hoặc bằng EndTime, cập nhật EndTime
                      _endTime = TimeOfDay(hour: pickedTime.hour + 1, minute: 0); // Tăng lên 1 giờ
                    }
                    _startTime = pickedTime;
                  });
                }
              },
              child: InputDecorator(
                decoration: Constants.customInputDecoration.copyWith(labelText: 'Start Time'),
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
                    // Chỉ cho phép chọn EndTime lớn hơn StartTime
                    if (pickedTime.hour < _startTime.hour ||
                        (pickedTime.hour == _startTime.hour && pickedTime.minute <= _startTime.minute)) {
                      // Nếu EndTime nhỏ hơn hoặc bằng StartTime, hiển thị thông báo lỗi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('End Time must be after Start Time')),
                      );
                    } else {
                      _endTime = pickedTime;
                    }
                  });
                }
              },
              child: InputDecorator(
                decoration: Constants.customInputDecoration.copyWith(labelText: 'End Time'),
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
        title: const Text('Create Schedule',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, size: 22),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC)),
            ),
            onPressed: submit,
            child: const Text(
              'Create',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Schedule Summary'),
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
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Organizer'),
                  items: _users.map((User user) {
                    return DropdownMenuItem<String>(
                      value: user.id.toString(),
                      child: Text(user.displayName ?? ""),
                    );
                  }).toList(),
                  onChanged: null,
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
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Room'),
                  items: _rooms.map((Room room) {
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
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Date'),
                    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16.0),
                ..._buildTimePickers(),
                const SizedBox(height: 16.0),
                ..._buildColorPicker(),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: Constants.customInputDecoration.copyWith(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}