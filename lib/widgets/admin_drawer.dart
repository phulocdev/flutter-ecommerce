import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/providers/cart_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:flutter_ecommerce/utils/util.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdminDrawer extends ConsumerWidget {
  final int? selectedIndex;
  final Function(int) onItemTapped;

  late final TokenService _tokenService;
  late final ApiClient _apiClient;
  late final AuthApiService _authApiService;

  AdminDrawer({super.key, required this.onItemTapped, this.selectedIndex}) {
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
                  ref.read(cartProvider.notifier).clearCart();
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.indigo),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Flutter TDTU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildListTile(
            context,
            index: 0,
            icon: Icons.dashboard,
            title: 'Dashboard',
          ),
          _buildListTile(
            context,
            index: 1,
            icon: Icons.people,
            title: 'Quản lý người dùng',
          ),
          _buildListTile(
            context,
            index: 2,
            icon: Icons.shopping_bag,
            title: 'Quản lý sản phẩm',
          ),
          _buildListTile(
            context,
            index: 3,
            icon: Icons.receipt,
            title: 'Quản lý đơn hàng',
          ),
          _buildListTile(
            context,
            index: 4,
            icon: Icons.discount,
            title: 'Quản lý phiếu giảm giá',
          ),
          _buildListTile(
            context,
            index: 5,
            icon: Icons.support_agent,
            title: 'Hỗ trợ khách hàng',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selectedIndex == index,
      selectedTileColor: Colors.indigo.withOpacity(0.1),
      onTap: () {
        onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
