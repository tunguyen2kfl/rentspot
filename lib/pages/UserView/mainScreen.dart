import 'package:flutter/material.dart';
import 'package:rent_spot/api/buildingApi.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/components/CustomAppBar.dart';
import 'package:rent_spot/components/SideBar.dart';
import 'package:rent_spot/models/building.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/pages/UserView/createSchedule.dart';
import 'package:rent_spot/pages/UserView/schedule.dart';
import 'package:rent_spot/pages/UserView/scheduleManager.dart';
import 'package:rent_spot/pages/viewBuilding.dart';
import 'package:rent_spot/stores/building.dart';
import 'package:rent_spot/stores/userData.dart';
import 'home.dart';
import 'profile.dart';
import 'schedule.dart';

class MainScreen extends StatefulWidget {
  final int initialPageIndex;
  const MainScreen({super.key, this.initialPageIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserApi userApi = UserApi(UserData());
  final BuildingApi buildingApi = BuildingApi(BuildingData());

  final List<Widget> _pages = [
    SchedulesView(),
    MySchedulesView(),
    BuildingInformationView()
  ];

  final List<String> _titles = ['Schedule', 'Schedule Manager', 'Building'];

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
      final buildingId = await storage.read(key: 'buildingId');
      if (buildingId != null) {
        Building success =
            await buildingApi.fetchBuildingById(int.parse(buildingId));
      }
    } catch (e) {
      print("Error getting user info: $e");
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
          color: Colors.white, // Set background color to white
          notchMargin: 100, // Create a notch for the FAB
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavBarItem(Icons.home, 'Schedules', 0),
              buildNavBarItem(Icons.calendar_month, 'Manager', 1),
              ClipOval(
                child: Material(
                  color: Color(0xFF3DA9FC),
                  child: InkWell(
                    onTap: () {
                      switch (_selectedIndex) {
                        case 0:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateSchedulePage()));
                          break;
                        case 1:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateSchedulePage()));
                          break;
                        case 2:
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreateSchedulePage()));
                          break;
                        default:
                          break;
                      }
                    },
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: Icon(Icons.add, size: 25, color: Colors.white),
                    ),
                  ),
                ),
              ),
              buildNavBarItem(Icons.calendar_month, 'Manager', 1),
              buildNavBarItem(Icons.maps_home_work_outlined, 'Building', 2),
            ],
          ),
        ),
      ),
      // Centered Add button
      // floatingActionButton: Padding(
      //   padding: EdgeInsets.only(top: 20), // Lower the FAB
      //   child: ClipOval(
      //     child: Material(
      //       color: Color(0xFF3DA9FC),
      //       child: InkWell(
      //         onTap: () {
      //           switch (_selectedIndex) {
      //             case 0:
      //               Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSchedulePage()));
      //               break;
      //             case 1:
      //               Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSchedulePage()));
      //               break;
      //             case 2:
      //               Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSchedulePage()));
      //               break;
      //             default:
      //               break;
      //           }
      //         },
      //         child: SizedBox(
      //           width: 56,
      //           height: 56,
      //           child: Icon(Icons.add, size: 35, color: Colors.white),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
