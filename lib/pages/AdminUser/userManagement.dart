import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/models/user.dart';
import 'package:rent_spot/stores/userData.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late Future<List<User>> usersFuture;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userApi = UserApi(UserData());
    try {
      usersFuture = userApi.getAllUserInBuilding(context);
      setState(() {});
    } catch (e) {
      print('Failed to load users: $e');
    }
  }

  Future<void> removeUserFromBuilding(String userId) async {
    final userApi = UserApi(UserData());
    try {
      bool success = await userApi.removeUserFromBuilding(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Remove user success"),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Remove user fail"),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      print('Failed to load users: $e');
    }
    setState(() {
      _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      user.avatar != null && user.avatar!.isNotEmpty
                          ? NetworkImage('${Constants.apiUrl}${user.avatar}')
                          : null,
                  child: user.avatar == null
                      ? Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                ),
                title: Text(user.displayName ?? 'Unknown User'),
                subtitle: Text(user.email ?? 'No Email'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    removeUserFromBuilding(user.id.toString());
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
