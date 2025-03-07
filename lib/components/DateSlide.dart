import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSlider extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSlider({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _DateSliderState createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  late List<DateTime> _dateList;
  late ScrollController _scrollController;
  late DateTime _currentSelectedDate;

  @override
  void initState() {
    super.initState();
    _currentSelectedDate = widget.selectedDate;
    _setupDateList();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(DateSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _currentSelectedDate = widget.selectedDate;
        _setupDateList();
      });

      // Thực hiện hành động khi selectedDate thay đổi
      print("Selected date changed to: ${widget.selectedDate}");
    }
  }

  void _setupDateList() {
    _dateList = _generateDateList(_currentSelectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _generateDateList(DateTime centerDate) {
    return List.generate(
      30,
          (index) => centerDate.subtract(const Duration(days: 14)).add(Duration(days: index)),
    );
  }

  void _scrollToSelectedDate() {
    if (!mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 80;
    final centerOffset = (screenWidth / 2) - (itemWidth / 2);

    final index = _dateList.indexWhere((date) =>
    date.year == _currentSelectedDate.year &&
        date.month == _currentSelectedDate.month &&
        date.day == _currentSelectedDate.day
    );

    if (index != -1) {
      final scrollOffset = index * itemWidth - centerOffset;

      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Color _getDateBackgroundColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day);
    final currentDay = DateTime(date.year, date.month, date.day);

    if (currentDay == selectedDay) {
      return Colors.blueAccent;
    } else if (currentDay == today) {
      return Colors.greenAccent;
    }
    return Colors.white;
  }

  Color _getDateTextColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day);
    final currentDay = DateTime(date.year, date.month, date.day);

    if (currentDay == selectedDay || currentDay == today) {
      return Colors.white;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dateList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = _dateList[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentSelectedDate = date;
              });
              widget.onDateSelected(date);

              // Thực hiện hành động ngay khi người dùng chọn một ngày mới
              print("User selected date: $date");
            },
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                color: _getDateBackgroundColor(date),
                borderRadius: BorderRadius.circular(10),
                border: DateTime(date.year, date.month, date.day) != DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day)
                    ? Border.all(color: Colors.grey.shade300)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDateTextColor(date),
                      fontWeight: DateTime(date.year, date.month, date.day) == DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 20,
                      color: _getDateTextColor(date),
                      fontWeight: DateTime(date.year, date.month, date.day) == DateTime(_currentSelectedDate.year, _currentSelectedDate.month, _currentSelectedDate.day)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}