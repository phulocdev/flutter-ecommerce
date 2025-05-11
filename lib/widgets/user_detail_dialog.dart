import 'package:flutter/material.dart';
import '../models/user.dart';

class UserDetailDialog extends StatelessWidget {
  final User user;

  const UserDetailDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('User Details: ${user.fullName}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('ID', user.id),
            _buildDetailRow('fullName', user.fullName),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Role', user.role),
            _buildDetailRow('Created At',
                '${user.createdAt?.day}/${user.createdAt?.month}/${user.createdAt?.year}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}