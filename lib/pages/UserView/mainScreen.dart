import 'package:flutter/material.dart';
import 'package:rent_spot/pages/UserView/schedule.dart';
import 'home.dart';
import 'profile.dart';
import 'schedule.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home page

  final List<Widget> _pages = [
    SchedulesView(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              buildNavBarItem(Icons.home, 'Home', 0),
              const SizedBox(width: 20),
              buildNavBarItem(Icons.person, 'Profile', 1),
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
