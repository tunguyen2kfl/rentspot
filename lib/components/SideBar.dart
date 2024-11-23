import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:rent_spot/pages/login.dart';
import 'package:rent_spot/stores/userData.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    final storage = FlutterSecureStorage();

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Căn chỉnh các item để chiếm hết chiều dài
          children: [
            // Avatar và thông tin người dùng
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userData.avatar ?? 'https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 10),
            Text(userData.displayName ?? 'User Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(userData.username != null ? '@${userData.username}' : '@username', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Nút Outline View Profile
            OutlinedButton(
              onPressed: () {
                // Hành động cho View Profile
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF3DA9FC)), // Màu outline
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Radius
                padding: EdgeInsets.symmetric(vertical: 5), // Padding cho nút
              ),
              child: Text('View Profile'),
            ),
            const SizedBox(height: 20),

            // Kiểm tra nếu có buildings
            if (userData.buildings != null && userData.buildings!.isNotEmpty) ...[
              // Tiêu đề Joined Buildings
              Text('Joined Buildings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Danh sách các building đã tham gia
              Expanded(
                child: ListView.builder(
                  itemCount: userData.buildings!.length,
                  itemBuilder: (context, index) {
                    final building = userData.buildings![index];
                    return ListTile(
                      title: Text(building),
                      trailing: TextButton(
                        onPressed: () {
                          // Hành động cho nút Out
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF3DA9FC), // Màu chữ
                        ),
                        child: Text('Out'),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Nút Log Out ở dưới cùng
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Xóa toàn bộ dữ liệu lưu trữ
                await storage.deleteAll(); // Xóa tất cả dữ liệu lưu trữ

                // Điều hướng đến màn hình đăng nhập
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Thay đổi tên lớp nếu cần
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3DA9FC), // Màu nền
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Radius
                ),
                padding: EdgeInsets.symmetric(vertical: 15), // Padding cho nút
              ),
              child: Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}