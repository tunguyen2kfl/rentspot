// home_page.dart
import 'package:flutter/material.dart';
import 'package:rent_spot/components/CustomAppBar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My View',
        onBackButtonPressed: () {
          Navigator.pop(context); // Handle back button press
        },
        onSidebarButtonPressed: () {
          // Handle sidebar button press (e.g., open a drawer)
        },
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
