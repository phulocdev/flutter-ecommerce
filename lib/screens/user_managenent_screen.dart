import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/widgets/user_form_dialog.dart';
import 'package:flutter_ecommerce/widgets/user_management_table.dart';
import '../../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<User> _users = [
    User(
      id: '1',
      email: 'admin@example.com',
      fullName: 'Admin User',
      role: 'Admin',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isActive: true,
      phone: '0123456789',
    ),
    User(
      id: '2',
      email: 'customer1@example.com',
      fullName: 'John Doe',
      role: 'Customer',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
      phone: '0987654321',
      address: '123 Main St, City',
    ),
    User(
      id: '3',
      email: 'customer2@example.com',
      fullName: 'Jane Smith',
      role: 'Customer',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isActive: false,
    ),
  ];

  void _addUser(User user) {
    setState(() {
      _users.add(user.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        isActive: true,
      ));
    });
  }

  void _updateUser(User updatedUser) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
    });
  }

  void _deleteUser(String userId) {
    setState(() {
      _users.removeWhere((user) => user.id == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeUsers = _users.where((user) => user.isActive == true).length;
    final adminUsers = _users.where((user) => user.role == 'Admin').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Stats Cards
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Total Users',
                      value: _users.length,
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'Active Users',
                      value: activeUsers,
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'Admin Users',
                      value: adminUsers,
                      icon: Icons.admin_panel_settings,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'New Today',
                      value: _users
                          .where((user) => user.createdAt != null &&
                              user.createdAt!.day == DateTime.now().day)
                          .length,
                      icon: Icons.new_releases,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Management Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User Management',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add User'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => UserFormDialog(
                                  onSave: _addUser,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search and Filter Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search users...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilterChip(
                            label: const Text('Active'),
                            selected: true,
                            onSelected: (bool value) {},
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Admins'),
                            onSelected: (bool value) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      UserManagementTable(
                        users: _users,
                        onDelete: _deleteUser,
                        onEdit: _updateUser, onToggleAdmin: (String userId) {  },
                      ),
                      const SizedBox(height: 16),
                      // Pagination and Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${_users.length} of ${_users.length} users',
                            style: theme.textTheme.bodySmall,
                          ),
                          Row(
                            children: [
                              const Text('Rows per page: '),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: 10,
                                items: [5, 10, 25, 50]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text('$e'),
                                        ))
                                    .toList(),
                                onChanged: (value) {},
                              ),
                              const SizedBox(width: 16),
                              const Text('Page 1 of 1'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}