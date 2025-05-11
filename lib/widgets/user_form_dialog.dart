import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/user.dart';

class UserFormDialog extends StatefulWidget {
  final Function(User) onSave;
  final User? user;

  const UserFormDialog({
    super.key,
    required this.onSave,
    this.user,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  late final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
      text: widget.user?.email ?? '');
  late final _fullNameController = TextEditingController(
      text: widget.user?.fullName ?? '');
  late final _phoneController = TextEditingController(
      text: widget.user?.phone ?? '');
  late final _addressController = TextEditingController(
      text: widget.user?.address ?? '');
  late String _role = widget.user?.role ?? 'Customer';
  late bool _isActive = widget.user?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null 
          ? 'Add New User' 
          : 'Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: ['Admin', 'Customer']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final user = User(
                id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                email: _emailController.text,
                fullName: _fullNameController.text,
                role: _role,
                phone: _phoneController.text,
                address: _addressController.text,
                isActive: _isActive,
                createdAt: widget.user?.createdAt ?? DateTime.now(),
              );
              widget.onSave(user);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.user == null
                      ? 'User created successfully'
                      : 'User updated successfully'),
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}