import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/user.dart';

class UserFormDialog extends StatefulWidget {
  final User? user;
  final Function(User) onSave;

  const UserFormDialog({
    super.key,
    this.user,
    required this.onSave,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedRole = 'Customer';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _phoneController.text = widget.user!.phone ?? '';
      _addressController.text = widget.user!.address ?? '';
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text,
        email: _emailController.text,
        role: _selectedRole,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address:
            _addressController.text.isEmpty ? null : _addressController.text,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        isActive: _isActive,
      );

      widget.onSave(user);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.user == null ? 'Thêm người dùng mới' : 'Chỉnh sửa người dùng'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Vui lòng nhập email hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Role
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'Admin',
                    child: Text('Quản trị viên'),
                  ),
                  DropdownMenuItem(
                    value: 'Staff',
                    child: Text('Nhân viên'),
                  ),
                  DropdownMenuItem(
                    value: 'Customer',
                    child: Text('Khách hàng'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Trạng thái hoạt động'),
                subtitle: Text(_isActive ? 'Đang hoạt động' : 'Đã khóa'),
                value: _isActive,
                activeColor: Colors.green,
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
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.user == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
