import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
              child: Image.asset(
                'assets/images/Logo.png', // Replace with your logo path
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10), // Space between logo and loading indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0), // Add horizontal padding
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3DA9FC)),
                backgroundColor: Colors.white, // Change color as needed
                minHeight: 5, // Thickness of the progress indicator
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}