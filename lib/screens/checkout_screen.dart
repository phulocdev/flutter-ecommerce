import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String phoneNumber = '';
  String address = '';
  String paymentMethod = 'credit_card';

  // Sample order items - in a real app, these would come from your cart
  final List<Map<String, dynamic>> orderItems = [
    {'name': 'Product 1', 'quantity': 2, 'price': 25.99},
    {'name': 'Product 2', 'quantity': 1, 'price': 34.50},
  ];

  double get subtotal => orderItems.fold(
      0, (sum, item) => sum + (item['quantity'] * item['price']));
  double get shipping => 5.99;
  double get total => subtotal + shipping;

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Show a more attractive loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate processing
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Đặt hàng thành công'),
            content: const Text(
                'Cảm ơn bạn đã đặt hàng. Chúng tôi sẽ xử lý đơn hàng của bạn ngay lập tức.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: Colors.grey.shade300, thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Phương thức thanh toán'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(Icons.account_balance,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    const Text('Chuyển khoản ngân hàng'),
                  ],
                ),
                value: 'bank_transfer',
                groupValue: paymentMethod,
                onChanged: (value) => setState(() => paymentMethod = value!),
                activeColor: Theme.of(context).primaryColor,
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<String>(
                title: Row(
                  children: [
                    Icon(Icons.money, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    const Text('Thanh toán khi nhận hàng (COD)'),
                  ],
                ),
                value: 'cod',
                groupValue: paymentMethod,
                onChanged: (value) => setState(() => paymentMethod = value!),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tóm tắt đơn hàng'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']} x${item['quantity']}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            '${(item['price'] * item['quantity']).toStringAsFixed(2)}đ',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
                Divider(color: Colors.grey.shade300),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính'),
                      Text('${subtotal.toStringAsFixed(2)}đ'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí vận chuyển'),
                      Text('${shipping.toStringAsFixed(2)}đ'),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade300),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)}đ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin giao hàng'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Họ và tên',
                            icon: Icons.person,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập tên'
                              : null,
                          onSaved: (value) => name = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Email',
                            icon: Icons.email,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                                  ? 'Email không hợp lệ'
                                  : null,
                          onSaved: (value) => email = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Số điện thoại',
                            icon: Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value == null || value.length < 9
                                  ? 'Số điện thoại không hợp lệ'
                                  : null,
                          onSaved: (value) => phoneNumber = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            label: 'Địa chỉ nhận hàng',
                            icon: Icons.location_on,
                          ),
                          maxLines: 2,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập địa chỉ'
                              : null,
                          onSaved: (value) => address = value!,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildPaymentMethodSelector(),
                _buildOrderSummary(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Xác nhận thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
