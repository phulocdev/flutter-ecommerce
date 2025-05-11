import 'package:flutter/material.dart';
import 'admin_layout_scaffold.dart'; 
import 'simple_dashboard_view.dart'; 
import 'advanced_dashboard_view.dart'; 

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _showAdvanced = false; 

  @override
  Widget build(BuildContext context) {
    return AdminLayoutScaffold(
      title: 'Dashboard',
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAdvanced = !_showAdvanced; 
                  });
                },
                child: Text(_showAdvanced ? 'Simple' : 'Advanced'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _showAdvanced ? const AdvancedDashboardView() : const SimpleDashboardView(),
          ),
        ],
      ),
    );
  }
}