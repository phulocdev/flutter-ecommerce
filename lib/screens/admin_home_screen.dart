import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/screens/dashboard.dart';
import 'package:flutter_ecommerce/screens/user_managenent_screen.dart';
import 'package:flutter_ecommerce/widgets/admin_drawer.dart';

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
    const Placeholder(), // Product Management
    const Placeholder(), // Order Management
    const Placeholder(), // Coupon Management
    const Placeholder(), // Customer Support
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
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
      case 0: return 'Dashboard';
      case 1: return 'User Management';
      case 2: return 'Product Management';
      case 3: return 'Order Management';
      case 4: return 'Coupon Management';
      case 5: return 'Customer Support';
      default: return 'Admin Panel';
    }
  }
}