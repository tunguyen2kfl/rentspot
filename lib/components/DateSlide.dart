import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSlider extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DateSlider({
    Key? key,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _DateSliderState createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  late DateTime _selectedDate;
  late List<DateTime> _dateList;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateList = _generateDateList(_selectedDate);
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đợi layout hoàn tất mới thực hiện scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenWidth = MediaQuery.of(context).size.width;
        final initialScrollOffset = screenWidth * 0.5 * 14;
        _scrollController.jumpTo(initialScrollOffset);
      }
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
            (index) => centerDate.subtract(const Duration(days: 14)).add(Duration(days: index))
    );
  }

  Color _getDateBackgroundColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final currentDay = DateTime(date.year, date.month, date.day);

    if (currentDay == selectedDay) {
      return Colors.blueAccent; // Màu nền cho ngày được chọn
    } else if (currentDay == today) {
      return Colors.greenAccent; // Màu nền cho ngày hôm nay
    }
    return Colors.white; // Màu nền trắng cho các ngày khác
  }

  Color _getDateTextColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final currentDay = DateTime(date.year, date.month, date.day);

    if (currentDay == selectedDay || currentDay == today) {
      return Colors.white; // Màu chữ trắng cho ngày được chọn và ngày hôm nay
    }
    return Colors.black; // Màu chữ đen cho các ngày khác
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
              final currentDay = DateTime(date.year, date.month, date.day);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _dateList = _generateDateList(_selectedDate);
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: _getDateBackgroundColor(date),
                    borderRadius: BorderRadius.circular(10),
                    border: currentDay != selectedDay && currentDay != today
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
                          fontWeight: currentDay == selectedDay
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 20,
                          color: _getDateTextColor(date),
                          fontWeight: currentDay == selectedDay
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
      },
    );
  }
}
