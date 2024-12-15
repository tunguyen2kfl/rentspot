import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/pages/login.dart';
import 'package:rent_spot/pages/profile.dart';
import 'package:rent_spot/stores/userData.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserData>(context, listen: false);
    userData.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final storage = FlutterSecureStorage();

    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData.avatar != null
                    ? NetworkImage('${Constants.apiUrl}${userData.avatar}')
                    : null,
                child: userData.avatar == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                userData.displayName ?? 'User Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                userData.username != null ? '@${userData.username}' : '@username',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Color(0xFF3DA9FC)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 5),
              ),
              child: Text('View Profile', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            if (userData.buildings != null && userData.buildings!.isNotEmpty) ...[
              Text(
                'Joined Buildings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: userData.buildings!.length,
                  itemBuilder: (context, index) {
                    final building = userData.buildings![index];
                    return ListTile(
                      title: Text(building),
                      trailing: TextButton(
                        onPressed: () {
                          // Hành động cho nút Out
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF3DA9FC), // Màu chữ
                        ),
                        child: Text('Out'),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await storage.deleteAll();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3DA9FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radius
                ),
                padding: EdgeInsets.symmetric(vertical: 15), // Padding cho nút
              ),
              child: Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}