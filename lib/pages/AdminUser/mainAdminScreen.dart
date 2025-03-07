import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/AdminUser/createDevice.dart';
import 'package:rent_spot/pages/AdminUser/createRoom.dart';
import 'package:rent_spot/pages/AdminUser/deviceManagement.dart';
import 'package:rent_spot/pages/AdminUser/roomMgmt.dart';
import 'package:rent_spot/pages/AdminUser/userManagement.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/pages/viewBuilding.dart';
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
  final FlutterSecureStorage storage = FlutterSecureStorage();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    WaitingScheduleView(),
    RoomManagementView(),
    DeviceManagementView(),
    BuildingInformationView(),
    UserManagementScreen()
  ];

  final List<String> _titles = [
    'Waiting Schedule',
    'Room Management',
    'Device management',
    'Building',
    'User Management'
  ];

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
      final buildingId = await storage.read(key: 'buildingId');
      if (buildingId != null) {
        Building success = await buildingApi
            .fetchBuildingById(int.parse(buildingId));
      }
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
    final userData = Provider.of<UserData>(context);
    print(userData.role);
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
              buildNavBarItem(Icons.maps_home_work_outlined, 'Building', 3),
              buildNavBarItem(Icons.supervised_user_circle, 'User', 4),
            ],
          ),
        ),
      ),
      // Centered Add button
      floatingActionButton: _selectedIndex != 0 && _selectedIndex != 3 && _selectedIndex != 4
          ? Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: ClipOval(
                child: Material(
                  color: Color(0xFF3DA9FC),
                  child: InkWell(
                    onTap: () {
                      switch (_selectedIndex) {
                        case 1:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateRoomView()));
                          break;
                        case 2:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateDeviceView()));
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
            )
          : null,
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
