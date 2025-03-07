import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/UserView/createSchedule.dart';
import 'package:rent_spot/pages/UserView/schedule.dart';
import 'package:rent_spot/pages/UserView/scheduleManager.dart';
import 'package:rent_spot/pages/UserView/scheduleMonth.dart';
import 'package:rent_spot/pages/viewBuilding.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/stores/userData.dart';

class MainScreen extends StatefulWidget {
  final int initialPageIndex;
  final DateTime? initialDate;

  const MainScreen({super.key, this.initialPageIndex = 0, this.initialDate});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserApi userApi = UserApi(UserData());
  final BuildingApi buildingApi = BuildingApi(BuildingData());

  late final List<Widget> _pages = [
    SchedulesView(initialDate: widget.initialDate),
    SchedulesMonthView(),
    MySchedulesView(),
    BuildingInformationView(),
  ];

  final List<String> _titles = [
    'Schedule',
    'Month Schedules',
    'Schedule Manager',
    'Building'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex;
    _getUserInfo();
    _getBuildingInfor();
  }

  Future<void> _getUserInfo() async {
    try {
      User user = await userApi.getUserInfo(context);
      print("User Info: ${user.toString()}");
    } catch (e) {
      print("Error getting user info: $e");
    }
  }

  Future<void> _getBuildingInfor() async {
    try {
      final FlutterSecureStorage storage = FlutterSecureStorage();
      final buildingId = await storage.read(key: 'buildingId');
      if (buildingId != null) {
        Building success = await buildingApi.fetchBuildingById(int.parse(buildingId));
      }
    } catch (e) {
      print("Error getting building info: $e");
    }
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
        },
      ),
      drawer: const SideMenu(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF3DA9FC).withOpacity(0.5),
              width: 0.3,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: buildNavBarItem(Icons.date_range, 'Day', 0)),
              Expanded(child: buildNavBarItem(Icons.calendar_month, 'Month', 1)),
              Expanded(child: buildNavBarItem(Icons.manage_history_outlined, 'Manager', 2)),
              Expanded(child: buildNavBarItem(Icons.maps_home_work_outlined, 'Building', 3)),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex < 3
          ? Padding(
        padding: const EdgeInsets.only(bottom: 80), // Hạ thấp nút FAB
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateSchedulePage()),
            );
          },
          backgroundColor: Color(0xFF3DA9FC),
          child: Icon(Icons.add, color: Colors.white),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
            color: _selectedIndex == index ? const Color(0xFF3DA9FC) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? const Color(0xFF3DA9FC) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}