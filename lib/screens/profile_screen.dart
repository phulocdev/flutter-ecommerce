import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Nguyễn Văn A'),
            accountEmail: Text('nguyenvana@example.com'),
            decoration: BoxDecoration(color: Colors.blue),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/avt.png'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Chỉnh sửa thông tin cá nhân'),
            onTap: () {
              context.go(AppRoute.editProfileScreen.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Thay đổi mật khẩu'),
            onTap: () {
              context.go(AppRoute.changePassword.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Quản lý địa chỉ giao hàng'),
            onTap: () {
              context.go(AppRoute.manageAddress.path);
            },
          ),
        ],
      ),
    );
  }
}
