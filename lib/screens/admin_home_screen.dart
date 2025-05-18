import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/screens/dashboard.dart';
import 'package:flutter_ecommerce/screens/order_management_screen.dart';
import 'package:flutter_ecommerce/screens/product_management_screen.dart';
import 'package:flutter_ecommerce/screens/user_managenent_screen.dart';
import 'package:flutter_ecommerce/widgets/admin_drawer.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboard(),
    const UserManagementScreen(),
    const ProductManagementScreen(), // Product Management
    const OrderManagementScreen(), // Order Management
    const Placeholder(), // Coupon Management
    const Placeholder(), // Customer Support
  ];

  final List<String> _paths = [
    AppRoute.adminHome.path,
    AppRoute.userManagement.path,
    AppRoute.productManagement.path,
    AppRoute.orderManagement.path,
    AppRoute.couponManagement.path,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // context.push(_paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _pages[_selectedIndex],
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'User Management';
      case 2:
        return 'Product Management';
      case 3:
        return 'Order Management';
      case 4:
        return 'Coupon Management';
      case 5:
        return 'Customer Support';
      default:
        return 'Admin Panel';
    }
  }
}
