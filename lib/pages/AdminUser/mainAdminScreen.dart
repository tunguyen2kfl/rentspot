import 'package:flutter/material.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/pages/AdminUser/roomMgmt.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/pages/UserView/schedule.dart';


class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen({super.key});

  @override
  _MainAdminScreenState createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // Default to Home page

  final List<Widget> _pages = [
    WaitingScheduleView(),
    RoomManagementView(),
  ];

  final List<String> _titles = [
    'Waiting Schedule',
    'Room Management'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        onSidebarButtonPressed: () {
          if (_scaffoldKey.currentState != null) {
            _scaffoldKey.currentState!.openDrawer(); // Mở sidebar
          }
        }
      ),
      drawer: const SideMenu(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF3DA9FC).withOpacity(0.5), // Reduce opacity
              width: 0.3,
            ), // Add top border
          ),
        ),
        child: BottomAppBar(
          color: Colors.white, // Set background color to white
          notchMargin: 100, // Create a notch for the FAB
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavBarItem(Icons.calendar_month, 'Schedules', 0),
              const SizedBox(width: 20),
              buildNavBarItem(Icons.meeting_room, 'Room', 1),
            ],
          ),
        ),
      ),
      // Centered Add button
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 0), // Lower the FAB
        child: ClipOval(
          child: Material(
            color: Color(0xFF3DA9FC),
            child: InkWell(
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, size: 35, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildNavBarItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
            _selectedIndex == index ? const Color(0xFF3DA9FC) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? const Color(0xFF3DA9FC)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
