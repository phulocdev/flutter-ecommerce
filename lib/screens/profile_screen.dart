import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  late final TokenService _tokenService;
  late final ApiClient _apiClient;
  late final AuthApiService _authApiService;

  ProfileScreen({super.key}) {
    _tokenService = TokenService();
    _apiClient = ApiClient();
    _authApiService = AuthApiService(_apiClient, _tokenService);
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () async {
                final refreshToken = await _tokenService.getRefreshToken();

                try {
                  await _authApiService.logoutWithApi(refreshToken ?? '');
                  Navigator.of(context).pop();
                  ref.read(authProvider.notifier).logout();
                  context.go(AppRoute.login.path);
                } catch (e) {
                  print('Lỗi khi đăng xuất: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isAuthenticated = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(isAuthenticated ? user.fullName : 'Khách'),
            accountEmail:
                Text(isAuthenticated ? user.email : 'Vui lòng đăng nhập'),
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avt.png'),
            ),
          ),
          if (isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Chỉnh sửa thông tin cá nhân'),
              onTap: () => context.push(AppRoute.editProfileScreen.path),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Thay đổi mật khẩu'),
              onTap: () => context.push(AppRoute.changePassword.path),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Quản lý địa chỉ giao hàng'),
              onTap: () => context.push(AppRoute.manageAddress.path),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Đăng xuất'),
              onTap: () => _showLogoutDialog(context, ref),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () => context.push(AppRoute.login.path),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Đăng ký'),
              onTap: () => context.push(AppRoute.register.path),
            ),
          ]
        ],
      ),
    );
  }
}
