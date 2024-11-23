import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/pages/AdminUser/waitingSchedule.dart';
import 'package:rent_spot/pages/NoRole/welcome.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/stores/userData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

const double _textFieldBorderRadius = 10;
const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;

// Reusable input decoration
final InputDecoration customInputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
    BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
    BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  labelStyle: TextStyle(color: _textFieldBorderColor), // Change label color to blue
);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _validateInputs() {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be empty')),
      );
      return false;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password cannot be empty')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final userApi = UserApi(userData);

    void login() async {
      print("LOGIN");
      setState(() {
        _isLoading = true;
      });

      if (!_validateInputs()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final res = await userApi.login(_usernameController.text, _passwordController.text);
        if (res.role == null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
        } else if (res.role == 'user') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else if (res.role == 'building-admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainAdminScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) { // Kiểm tra xem widget còn trong cây không
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  child: Image.asset(
                    'assets/images/Logo.png', // Replace with your logo path
                    height: 150,
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                // Input User Name
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _usernameController,
                    decoration: customInputDecoration.copyWith(labelText: 'Username'),
                  ),
                ),
                // Input Password
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: customInputDecoration.copyWith(labelText: 'Password'),
                  ),
                ),
                // Login Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      // Action for Login
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textFieldBorderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(0, 50),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // Register Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for Register
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF3DA9FC), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(0, 50),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: _textFieldBorderColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}