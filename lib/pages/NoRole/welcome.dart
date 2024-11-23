import 'package:flutter/material.dart';
import 'package:rent_spot/pages/NoRole/createBuilding.dart';
import 'package:rent_spot/pages/NoRole/joinBuilding.dart';
const double _textFieldBorderRadius = 5.0;
const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: Image.asset(
                    'assets/images/Logo.png', // Replace with your logo path
                    height: 150,
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                // Title
                Text(
                  'Welcome to RentSpot',
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                // Content
                SizedBox(height: 20), // Add spacing between title and content
                Text(
                  'Please take your action to start!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.25), // Adjust spacing to push buttons to the bottom
                // Create Building Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateBuildingView()));
                    },
                    icon: Icon(Icons.add_business, color: Colors.white,), // Example icon
                    label: Text('Create your building', style: TextStyle(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textFieldBorderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(0, 50),
                    ),
                  ),
                ),
                // Join Building Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinBuildingView()));
                    },
                    icon: Icon(Icons.group_add, color: _textFieldBorderColor,), // Example icon
                    label: Text('Join building', style: TextStyle(fontSize: 18, color: _textFieldBorderColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: _textFieldBorderColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(0, 50),
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