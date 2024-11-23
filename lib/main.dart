import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/pages/NoRole/welcome.dart';
import 'package:rent_spot/pages/login.dart';
import 'package:rent_spot/pages/splash.dart';
import 'package:rent_spot/stores/userData.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<bool> _loginFuture = _checkLoginStatus();

  Future<bool> _checkLoginStatus() async {
    print('Starting check login status...');
    final userData = Provider.of<UserData>(context, listen: false);
    await Future.delayed(const Duration(seconds: 2));

    String? accessToken = await userData.storage.read(key: 'accessToken');
    print('Access token read: $accessToken');

    if (accessToken != null) {
      await userData.loadUserData();
      print('User data loaded');
      return true;
    } else {
      print('No access token found');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Raleway',
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3DA9FC)),
          ),
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        // Sử dụng _loginFuture đã được khởi tạo trong initState
        future: _loginFuture,
        builder: (context, snapshot) {
          print('FutureBuilder state: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          return _navigateToNextScreen(userData);
        },
      ),
    );
  }

  Widget _navigateToNextScreen(UserData userData) {
    if (userData.accessToken == null) {
      return LoginScreen();
    } else {
      if (userData.role == null) {
        return WelcomeScreen();
      } else if (userData.role == 'user') {
        return MainScreen();
      } else if (userData.role == 'buildingAdmin') {
        return WaitingScheduleView();
      } else {
        return WelcomeScreen();
      }
    }
  }
}
