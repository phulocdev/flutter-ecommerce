import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/models/coupon.dart';
import 'package:flutter_ecommerce/models/dto/create_coupon_dto.dart';

class CouponFormDialog extends StatefulWidget {
  final Coupon? coupon;
  final Function(CreateCouponDto) onCreate;
  final Function(String, bool)? onToggleStatus;

  const CouponFormDialog({
    Key? key,
    this.coupon,
    required this.onCreate,
    this.onToggleStatus,
  }) : super(key: key);

  @override
  State<CouponFormDialog> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  int _discountAmount = 10000;
  int _maxUsage = 1;

  final List<int> _discountOptions = [10000, 20000, 50000, 100000];

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _codeController.text = widget.coupon!.code;
      _discountAmount = widget.coupon!.discountAmount;
      _maxUsage = widget.coupon!.maxUsage;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dto = CreateCouponDto(
        code: _codeController.text.trim().toUpperCase(),
        discountAmount: _discountAmount,
        maxUsage: _maxUsage,
      );
      widget.onCreate(dto);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.coupon != null;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(isEditing ? 'Chi tiết mã giảm giá' : 'Tạo mã giảm giá mới'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Code field
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Mã giảm giá',
                    hintText: 'Nhập mã giảm giá (5 ký tự)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.0),
                    ),
                    prefixIcon: const Icon(Icons.code),
                  ),
                  enabled: !isEditing, // Can't edit code for existing coupons
                  maxLength: 5,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã giảm giá';
                    }
                    if (value.length != 5) {
                      return 'Mã giảm giá phải có đúng 5 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Discount amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá trị giảm giá',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _discountOptions.map((amount) {
                        return ChoiceChip(
                          label: Text(
                            '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VND',
                          ),
                          selected: _discountAmount == amount,
                          onSelected: isEditing
                              ? null
                              : (selected) {
                                  if (selected) {
                                    setState(() {
                                      _discountAmount = amount;
                                    });
                                  }
                                },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _discountAmount == amount
                                ? colorScheme.primary
                                : Colors.black87,
                            fontWeight: _discountAmount == amount
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Max usage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số lần sử dụng tối đa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _maxUsage.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _maxUsage.toString(),
                      onChanged: isEditing
                          ? null
                          : (value) {
                              setState(() {
                                _maxUsage = value.round();
                              });
                            },
                    ),
                    Text(
                      'Mã giảm giá có thể sử dụng tối đa $_maxUsage lần',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                // Show usage info for existing coupons
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Thông tin sử dụng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Ngày tạo:',
                    widget.coupon!.createdAt.toString().substring(0, 10),
                  ),
                  _buildInfoRow(
                    'Đã sử dụng:',
                    '${widget.coupon!.usageCount}/${widget.coupon!.maxUsage} lần',
                  ),
                  _buildInfoRow(
                    'Còn lại:',
                    '${widget.coupon!.remainingUsage} lần',
                  ),
                  _buildInfoRow(
                    'Trạng thái:',
                    widget.coupon!.isActive ? 'Đang hoạt động' : 'Đã vô hiệu',
                    valueColor:
                        widget.coupon!.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Toggle status button for existing coupons
        if (isEditing && widget.onToggleStatus != null)
          TextButton.icon(
            icon: Icon(
              widget.coupon!.isActive ? Icons.block : Icons.check_circle,
              color: widget.coupon!.isActive ? Colors.red : Colors.green,
            ),
            label: Text(
              widget.coupon!.isActive ? 'Vô hiệu hóa mã' : 'Kích hoạt mã',
              style: TextStyle(
                color: widget.coupon!.isActive ? Colors.red : Colors.green,
              ),
            ),
            onPressed: () {
              widget.onToggleStatus!(
                widget.coupon!.id,
                !widget.coupon!.isActive,
              );
              Navigator.pop(context);
            },
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        if (!isEditing)
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tạo mã giảm giá'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight:
                  valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
