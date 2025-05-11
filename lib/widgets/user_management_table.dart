import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/widgets/user_detail_dialog.dart';
import 'package:flutter_ecommerce/widgets/user_form_dialog.dart';
import '../models/user.dart';

class UserManagementTable extends StatelessWidget {
  final List<User> users;
  final Function(String) onDelete;
  final Function(User) onEdit;

  const UserManagementTable({
    super.key,
    required this.users,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Text(user.email),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Text(user.phone ?? '-'),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user.role,
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Text(user.createdAt != null
                            ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                            : '-'),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Chip(
                          label: Text(
                            (user.isActive ?? true) ? 'Active' : 'Inactive',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: (user.isActive ?? true)
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onTap: () => _showUserDetails(context, user),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit user',
                              onPressed: () => _showEditDialog(context, user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete user',
                              onPressed: () =>
                                  _showDeleteConfirmation(context, user.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) => Colors.grey.shade50,
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08);
                    }
                    return null;
                  },
                ),
                columnSpacing: 24,
                horizontalMargin: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showUserDetails(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  void _showEditDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
        onSave: onEdit,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
