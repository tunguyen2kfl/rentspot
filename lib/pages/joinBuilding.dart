import 'package:flutter/material.dart';

class JoinBuildingView extends StatelessWidget {
  final TextEditingController _buildingCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Building'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/Logo.png', // Replace with your logo path
                  height: 150,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'Join building using the code',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _buildingCodeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Building Code',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Logic to join building using the code
                  String buildingCode = _buildingCodeController.text;
                  // Thực hiện hành động join building ở đây
                  print('Joining building with code: $buildingCode');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3DA9FC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: Size(double.infinity, 50), // Đặt chiều rộng là 100%
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}