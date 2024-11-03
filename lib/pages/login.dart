import 'package:flutter/material.dart';

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
  // hintStyle: TextStyle(color: Colors.grey), // Change hint color to grey
);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Username'),
                  ),
                ),
                // Input Password
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration:
                        customInputDecoration.copyWith(labelText: 'Password'),
                  ),
                ),
                // Login Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
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
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Set your desired font size here
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
                      // Action for Login
                      login();
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
                        fontSize: 18, // Set your desired font size here
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

  void login() {
    // Print input values
    print("Username: ${_usernameController.text}");
    print("Password: ${_passwordController.text}");
  }

// ... (register() function remains the same)
}
