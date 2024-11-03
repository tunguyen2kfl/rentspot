import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: Image.asset(
            'assets/images/Logo.png', // Replace with your logo path
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}