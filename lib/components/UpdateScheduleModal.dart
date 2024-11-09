import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class UpdateScheduleModal extends StatefulWidget {
  final Appointment appointment;
  const UpdateScheduleModal({Key? key, required this.appointment})
      : super(key: key);

  @override
  _UpdateScheduleModalState createState() => _UpdateScheduleModalState();
}

class _UpdateScheduleModalState extends State<UpdateScheduleModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _summaryController;
  late TextEditingController _organizerController;
  late List<String> _attendees;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColor;
  late TextEditingController _descriptionController;
  late TextEditingController _attendeeController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _summaryController =
        TextEditingController(text: widget.appointment.subject);
    _organizerController =
        TextEditingController(); // Initialize with existing data if available
    _attendees = []; // Initialize with existing data if available
    _attendeeController = TextEditingController();
    _startTime = TimeOfDay.fromDateTime(widget.appointment.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.appointment.endTime);
    _selectedColor = widget.appointment.color.value;
    _selectedDate = DateTime.now();
    _descriptionController =
        TextEditingController(); // Initialize with existing data if available
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      // Get values from controllers and other fields
      final String summary = _summaryController.text;
      final String organizer = _organizerController.text;
      final List<String> attendees = _attendees;
      final TimeOfDay startTime = _startTime;
      final TimeOfDay endTime = _endTime;
      final int colors = _selectedColor;
      final String description = _descriptionController.text;
      final DateTime selectedDate = _selectedDate;


      print(summary);
      print(organizer);
      print(attendees);
      print(startTime);
      print(endTime);
      print(colors);
      print(description);
      print(_selectedDate);

      // Navigator.pop(context); // Close the modal
    }
  }

  List<Widget> _buildAttendeesSection() {
    return [
      TextFormField(
        controller: _attendeeController, // Controller for attendee email input
        decoration: const InputDecoration(hintText: 'Enter email'),
      ),
      const SizedBox(height: 10.0),
      ElevatedButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC))),
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
                    _startTime = pickedTime;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Start Time'),
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
                    _endTime = pickedTime;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'End Time'),
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
            color: Color(_selectedColor.isNaN ? 0xFFFFFF :_selectedColor),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    _attendeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Scaffold for full-screen layout
      appBar: AppBar(
        title: const Text('Update Schedule',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF3DA9FC))),
            onPressed: submit,
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          // Add padding to the Form
          padding: const EdgeInsets.all(16.0), // Adjust padding as needed
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _summaryController,
                  decoration:
                      const InputDecoration(labelText: 'Schedule Summary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a summary';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _organizerController,
                  decoration: const InputDecoration(labelText: 'Organizer'),
                ),
                const SizedBox(height: 16.0),
                // Attendees Section
                const Text('Attendees', textAlign: TextAlign.left),
                ..._buildAttendeesSection(),
                const SizedBox(height: 16.0),
                //DatePicker
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
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)), // Format date
                  ),
                ),
                const SizedBox(height: 16.0),
                // Start and End Time Pickers
                ..._buildTimePickers(),
                const SizedBox(height: 16.0),
                // Color Picker
                ..._buildColorPicker(),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3, // Allow multiple lines for description
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
