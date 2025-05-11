import 'package:flutter/material.dart';
import 'admin_menu_drawer.dart'; 

class AdminLayoutScaffold extends StatelessWidget {
  final Widget body; 
  final String? title; 

  const AdminLayoutScaffold({super.key, required this.body, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Admin Dashboard'), 
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
      ),
      drawer: const AdminMenuDrawer(), 
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: body,
      ),
    );
  }
}