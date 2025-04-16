import 'package:flutter/material.dart';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  final List<String> _addresses = [
    '123 Nguyễn Trãi, Q1, TP.HCM',
    '456 Lê Lợi, Q3, TP.HCM',
  ];

  void _addAddress() {
    String newAddress = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm địa chỉ mới'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Nhập địa chỉ'),
          onChanged: (value) {
            newAddress = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newAddress.trim().isNotEmpty) {
                setState(() {
                  _addresses.add(newAddress.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _removeAddress(int index) {
    setState(() {
      _addresses.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa địa chỉ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý địa chỉ')),
      body: _addresses.isEmpty
          ? const Center(child: Text('Chưa có địa chỉ nào'))
          : ListView.builder(
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(_addresses[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeAddress(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa chỉ mới',
      ),
    );
  }
}
