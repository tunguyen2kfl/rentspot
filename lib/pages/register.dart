import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/api/userApi.dart';
import 'package:rent_spot/common/constants.dart';
import 'package:rent_spot/pages/AdminUser/mainAdminScreen.dart';
import 'package:rent_spot/pages/NoRole/welcome.dart';
import 'package:rent_spot/pages/UserView/mainScreen.dart';
import 'package:rent_spot/pages/login.dart';
import 'package:rent_spot/stores/userData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterScreen(),
    );
  }
}

const double _textFieldBorderRadius = 10;
const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;

// // Reusable input decoration
// final InputDecoration customInputDecoration = InputDecoration(
//   enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(_textFieldBorderRadius),
//     borderSide: BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(_textFieldBorderRadius),
//     borderSide: BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
//   ),
//   border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(_textFieldBorderRadius),
//   ),
//   labelStyle: TextStyle(color: _textFieldBorderColor),
// );

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  bool _isLoading = false;

  bool _validateInputs() {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username cannot be empty')));
      return false;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password cannot be empty')));
      return false;
    }
    if (_rePasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Re-enter your password')));
      return false;
    }
    if (_passwordController.text != _rePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return false;
    }
    if (_emailController.text.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid email')));
      return false;
    }
    if (_displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Display name cannot be empty')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final userApi = UserApi(userData);

    void register() async {
      print("REGISTER");
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
        final success = await userApi.register(
          _usernameController.text,
          _passwordController.text,
          _emailController.text,
          _displayNameController.text,
        );
        if (success != null && success) {
          // Assuming successful registration
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register success!')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) {
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
                // Input Username
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _usernameController,
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Username'),
                  ),
                ),
                // Input Email
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Email'),
                  ),
                ),
                // Input Display Name
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _displayNameController,
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Display Name'),
                  ),
                ),
                // Input Password
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Password'),
                  ),
                ),
                // Input Re-Password
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: TextField(
                    controller: _rePasswordController,
                    obscureText: true,
                    decoration: Constants.customInputDecoration.copyWith(labelText: 'Re-enter Password'),
                  ),
                ),
                // Register Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      // Action for Register
                      register();
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
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // Back to Login Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
                      'Back to Login',
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