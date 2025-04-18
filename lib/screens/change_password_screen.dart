import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thay đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                validator: (value) =>
                    value!.isEmpty ? 'Nhập mật khẩu hiện tại' : null,
                onSaved: (value) => currentPassword = value!,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (value) =>
                    value!.length < 6 ? 'Tối thiểu 6 ký tự' : null,
                onSaved: (value) => newPassword = value!,
              ),
              TextFormField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Xác nhận mật khẩu'),
                validator: (value) =>
                    value != newPassword ? 'Không khớp' : null,
                onSaved: (value) => confirmPassword = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final form = _formKey.currentState!;
                  if (form.validate()) {
                    form.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi mật khẩu thành công')),
                    );
                  }
                },
                child: const Text('Đổi mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
