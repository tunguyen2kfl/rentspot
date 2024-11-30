import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/AdminUser/createDevice.dart';
import 'package:rent_spot/pages/AdminUser/createRoom.dart';
import 'package:rent_spot/pages/AdminUser/deviceManagement.dart';
import 'package:rent_spot/pages/AdminUser/roomMgmt.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/stores/userData.dart';

class MainAdminScreen extends StatefulWidget {
  final int initialPageIndex;

  const MainAdminScreen({super.key, this.initialPageIndex = 0});

  @override
  _MainAdminScreenState createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserApi userApi = UserApi(UserData());
  final BuildingApi buildingApi = BuildingApi(BuildingData());
  int _selectedIndex = 0; // Default to Home page

  final List<Widget> _pages = [
    WaitingScheduleView(),
    RoomManagementView(),
    DeviceManagementView(),
  ];

  final List<String> _titles = ['Waiting Schedule', 'Room Management', 'Device management'];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialPageIndex;
    _getUserInfo();
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
      bool success = await buildingApi
          .fetchBuildingById(int.parse(UserData().buildingId.toString()));
    } catch (e) {
      print("Error getting user info: $e");
    }
  }

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
          }),
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
          color: Colors.white,
          notchMargin: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavBarItem(Icons.calendar_month, 'Schedules', 0),
              buildNavBarItem(Icons.meeting_room, 'Room', 1),
              buildNavBarItem(Icons.devices_outlined, 'Device', 2),
            ],
          ),
        ),
      ),
      // Centered Add button
      floatingActionButton:  Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: ClipOval(
          child: Material(
            color: Color(0xFF3DA9FC),
            child: InkWell(
              onTap: () {
                switch (_selectedIndex) {
                  case 0:
                  // Thực hiện hành động cho trường hợp 0
                    break;
                  case 1:
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRoomView()));
                    break;
                  case 2:
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDeviceView()));
                    break;
                  default:
                    break;
                }
              },
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, size: 35, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
