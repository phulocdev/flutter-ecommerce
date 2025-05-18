import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart'; // cần thiết cho kIsWeb

class ProfileScreen extends ConsumerWidget {
  late final TokenService _tokenService;
  late final ApiClient _apiClient;
  late final AuthApiService _authApiService;

  ProfileScreen({super.key}) {
    _tokenService = TokenService();
    _apiClient = ApiClient();
    _authApiService = AuthApiService(_apiClient, _tokenService);
  }

  // void _navigate(BuildContext context, String path) {
  //   if (kIsWeb) {
  //     context.go(path);
  //   } else {
  //     context.push(path);
  //     print('k');
  //   }
  // }

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
                  navigateTo(context, AppRoute.login.path);
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
    final account = ref.watch(authProvider);
    final isAuthenticated = account != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              isAuthenticated ? account.fullName : 'Khách vãng lai',
            ),
            accountEmail: Text(
              isAuthenticated ? account.email : 'Vui lòng đăng nhập',
            ),
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: CircleAvatar(
              backgroundImage: isAuthenticated &&
                      account.avatarUrl != null &&
                      account.avatarUrl!.isNotEmpty
                  ? NetworkImage(account.avatarUrl!)
                  : const AssetImage('assets/images/avt.png') as ImageProvider,
            ),
          ),
          if (account?.role == "Admin")
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Quản lý cửa hàng'),
              onTap: () => navigateTo(context, AppRoute.adminHome.path),
            ),
          if (isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Xem lịch sử mua hàng'),
              onTap: () => {
                // if (kIsWeb)
                //   {context.go(AppRoute.historyOrders.path)}
                // else
                //   {context.push(AppRoute.historyOrders.path)}
                context.push(AppRoute.historyOrders.path)
              },

            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Chỉnh sửa thông tin cá nhân'),
              onTap: () => navigateTo(context, AppRoute.editProfileScreen.path),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Thay đổi mật khẩu'),
              onTap: () => navigateTo(context, AppRoute.changePassword.path),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Quản lý địa chỉ giao hàng'),
              onTap: () => navigateTo(context, AppRoute.manageAddress.path),
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
              onTap: () => navigateTo(context, AppRoute.login.path),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Đăng ký'),
              onTap: () => navigateTo(context, AppRoute.register.path),
            ),
          ],
        ],
      ),
    );
  }
}
