import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/widgets/custom_text_form_field.dart';
import 'package:flutter_ecommerce/widgets/responsive_builder.dart';

class Address {
  final String id;
  String name;
  String address;
  String phone;
  bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.isDefault = false,
  });
}

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  final List<Address> _addresses = [
    Address(
      id: '1',
      name: 'Nhà riêng',
      address: '123 Nguyễn Trãi, Quận 1, TP.HCM',
      phone: '0901234567',
      isDefault: true,
    ),
    Address(
      id: '2',
      name: 'Văn phòng',
      address: '456 Lê Lợi, Quận 3, TP.HCM',
      phone: '0909876543',
    ),
  ];

  bool _isLoading = false;
  Address? _addressToEdit;

  void _showAddressForm({Address? address}) {
    setState(() {
      _addressToEdit = address;
    });

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: address?.name ?? '');
    final _addressController =
        TextEditingController(text: address?.address ?? '');
    final _phoneController = TextEditingController(text: address?.phone ?? '');
    bool _isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: _nameController,
                  label: 'Tên địa chỉ (VD: Nhà, Công ty)',
                  prefixIcon: Icons.bookmark_border,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên địa chỉ' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _addressController,
                  label: 'Địa chỉ chi tiết',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Đặt làm địa chỉ mặc định'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).primaryColor,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (address == null) {
                  // Add new address
                  final newAddress = Address(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    address: _addressController.text,
                    phone: _phoneController.text,
                    isDefault: _isDefault,
                  );

                  setState(() {
                    // If new address is default, update other addresses
                    if (_isDefault) {
                      for (var addr in _addresses) {
                        addr.isDefault = false;
                      }
                    }
                    _addresses.add(newAddress);
                  });
                } else {
                  // Update existing address
                  setState(() {
                    // If this address is set as default, update other addresses
                    if (_isDefault && !address.isDefault) {
                      for (var addr in _addresses) {
                        addr.isDefault = false;
                      }
                    }

                    // Find and update the address
                    final index =
                        _addresses.indexWhere((a) => a.id == address.id);
                    if (index != -1) {
                      _addresses[index].name = _nameController.text;
                      _addresses[index].address = _addressController.text;
                      _addresses[index].phone = _phoneController.text;
                      _addresses[index].isDefault = _isDefault;
                    }
                  });
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(address == null
                        ? 'Đã thêm địa chỉ mới'
                        : 'Đã cập nhật địa chỉ'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(address == null ? 'Thêm' : 'Lưu'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _removeAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa địa chỉ "${address.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa địa chỉ'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(Address address) {
    setState(() {
      for (var addr in _addresses) {
        addr.isDefault = addr.id == address.id;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đặt "${address.name}" làm địa chỉ mặc định'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: Colors.lightBlue),
            SizedBox(width: 8),
            Text(
              'Quản lý địa chỉ',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm địa chỉ'),
        tooltip: 'Thêm địa chỉ mới',
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _addresses.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              return _buildAddressCard(_addresses[index]);
            },
          );
  }

  Widget _buildTabletLayout() {
    return _addresses.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              return _buildAddressCard(_addresses[index]);
            },
          );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(32),
        child: _addresses.isEmpty
            ? _buildEmptyState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Địa chỉ của bạn'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _addresses.length,
                      itemBuilder: (context, index) {
                        return _buildAddressCard(_addresses[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm địa chỉ để thuận tiện cho việc giao hàng',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddressForm(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm địa chỉ mới'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address.isDefault
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: address.isDefault ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  address.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      'Mặc định',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildAddressDetail('Địa chỉ:', address.address),
            const SizedBox(height: 8),
            _buildAddressDetail('Điện thoại:', address.phone),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  OutlinedButton.icon(
                    onPressed: () => _setDefaultAddress(address),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Đặt mặc định'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showAddressForm(address: address),
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _removeAddress(address),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
