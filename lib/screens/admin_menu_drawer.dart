import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class AdminMenuDrawer extends StatelessWidget {
  const AdminMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, 
            ),
            child: Text(
              'Admin Panel', 
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard), 
            title: const Text('Dashboard'), 
            onTap: () {
              context.go('/admin'); 
              Navigator.of(context).pop(); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Quản lý sản phẩm'),
            onTap: () {
              context.go('/admin/products'); 
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Quản lý đơn hàng'),
            onTap: () {
              context.go('/admin/orders');  
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Quản lý người dùng'),
            onTap: () {
              context.go('/admin/users'); 
              Navigator.of(context).pop();
            },
          ),

        ],
      ),
    );
  }
}