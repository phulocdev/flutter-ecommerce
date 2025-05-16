import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/dto/create_user_dto.dart';
import 'package:flutter_ecommerce/models/dto/update_user_dto.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter/services.dart';

class UserFormDialog extends StatefulWidget {
  final User? user;
  final Function(CreateUserDto)? onCreate;
  final Function(UpdateUserDto)? onUpdate;

  const UserFormDialog({super.key, this.user, this.onCreate, this.onUpdate});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedRole = 'Customer';
  bool _isActive = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    if (widget.user != null) {
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _passwordController.text = widget.user!.password;
      _phoneController.text = widget.user!.phoneNumber;
      _addressController.text = widget.user!.address;
      _selectedRole = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      if (widget.user != null) {
        final dto = UpdateUserDto(
          fullName: _fullNameController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
          role: _selectedRole,
          phoneNumber:
              _phoneController.text.isEmpty ? null : _phoneController.text,
          address:
              _addressController.text.isEmpty ? null : _addressController.text,
          isActive: _isActive,
        );
        if (widget.onUpdate != null) {
          widget.onUpdate!(dto);
        }
      } else {
        final dto = CreateUserDto(
          email: _emailController.text,
          fullName: _fullNameController.text,
          password: _passwordController.text,
          role: _selectedRole,
          phoneNumber:
              _phoneController.text.isEmpty ? null : _phoneController.text,
          address:
              _addressController.text.isEmpty ? null : _addressController.text,
          isActive: _isActive,
        );
        if (widget.onCreate != null) {
          widget.onCreate!(dto);
        }
      }

      // Close the dialog
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: FadeTransition(
        opacity: _animation,
        child: ScaleTransition(
          scale: _animation,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
              maxHeight: 550,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.user == null ? Icons.person_add : Icons.edit,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.user == null
                            ? 'Thêm người dùng mới'
                            : 'Chỉnh sửa người dùng',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: 'Đóng',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: isWideScreen
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _buildLeftFields(colorScheme)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: _buildRightFields(colorScheme)),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildLeftFields(colorScheme),
                                  const SizedBox(height: 16),
                                  _buildRightFields(colorScheme),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Hủy'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submitForm,
                        icon: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : Icon(
                                widget.user == null ? Icons.add : Icons.save),
                        label: Text(_isSubmitting
                            ? 'Đang xử lý...'
                            : (widget.user == null ? 'Thêm' : 'Lưu')),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin cơ bản', Icons.person),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _fullNameController,
          label: 'Họ và tên',
          prefixIcon: Icons.badge,
          validator: (value) =>
              value == null || value.isEmpty ? 'Vui lòng nhập họ và tên' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.user == null, // Only enable for new users
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Vui lòng nhập email hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Số điện thoại',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }

  Widget _buildRightFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin bổ sung', Icons.settings),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Địa chỉ',
          prefixIcon: Icons.location_on,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(),
        const SizedBox(height: 24),
        _buildStatusSwitch(colorScheme),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fixed border colors that will be consistent
    final borderColor = Colors.grey; // More visible border
    final errorColor = colorScheme.error;

    return Theme(
      // Override the default TextFormField theme to fix hover issues
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          // Ensure label and hint text have good contrast in all states
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),

          // Fix for error text color
          errorStyle: TextStyle(color: errorColor),
          // Fix hover behavior
          hoverColor: Colors.transparent,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,

        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
            color: colorScheme.onSurface), // Ensure text is always visible
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon,
              color: enabled
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.5)),
          // Always show a border, even when not focused
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Make sure unfocused fields still have a visible border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Focused border is more prominent
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          // Error borders are always visible
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 2.0),
          ),
          // Background color
          filled: true,
          fillColor: enabled
              ? colorScheme.surface
              : colorScheme.surfaceVariant.withOpacity(0.5),
          // Fix for hover issue - ensure error state is preserved on hover
          hoverColor: Colors.transparent,
          // Ensure good padding
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // Fix for error text
          errorMaxLines: 2,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fixed border colors
    final borderColor = Colors.grey;
    final errorColor = colorScheme.error;

    return Theme(
      // Override the default TextFormField theme to fix hover issues
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          errorStyle: TextStyle(color: errorColor),
          hoverColor: Colors.transparent,
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: widget.user == null
              ? 'Mật khẩu'
              : 'Mật khẩu (để trống nếu không thay đổi)',
          prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          // Always show a border, even when not focused
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Make sure unfocused fields still have a visible border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Focused border is more prominent
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          // Error borders are always visible
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 2.0),
          ),
          // Background color
          filled: true,
          fillColor: colorScheme.surface,
          // Fix for hover issue
          hoverColor: Colors.transparent,
          // Ensure good padding
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // Fix for error text
          errorMaxLines: 2,
        ),
        validator: (value) =>
            widget.user == null && (value == null || value.isEmpty)
                ? 'Vui lòng nhập mật khẩu'
                : null,
      ),
    );
  }

  Widget _buildDropdownField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fixed border colors
    final borderColor = Colors.grey;
    final errorColor = colorScheme.error;

    return Theme(
      // Override the default DropdownButtonFormField theme to fix hover issues
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          errorStyle: TextStyle(color: errorColor),
          hoverColor: Colors.transparent,
        ),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Vai trò',
          prefixIcon:
              Icon(Icons.admin_panel_settings, color: colorScheme.primary),
          // Always show a border, even when not focused
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Make sure unfocused fields still have a visible border
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.0),
          ),
          // Focused border is more prominent
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
          // Error borders are always visible
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: errorColor, width: 2.0),
          ),
          // Background color
          filled: true,
          fillColor: colorScheme.surface,
          // Fix for hover issue
          hoverColor: Colors.transparent,
          // Ensure good padding
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: _selectedRole,
        items: [
          DropdownMenuItem(
            value: 'Admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Quản trị viên'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Customer',
            child: Row(
              children: [
                Icon(Icons.person, color: colorScheme.secondary),
                const SizedBox(width: 8),
                const Text('Khách hàng'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRole = value;
            });
          }
        },
        validator: (value) => value == null ? 'Vui lòng chọn vai trò' : null,
        // Ensure dropdown text is always visible
        style: TextStyle(color: colorScheme.onSurface),
        // Fix dropdown icon color
        icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
        // Fix dropdown menu appearance
        dropdownColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildStatusSwitch(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: colorScheme.outline.withOpacity(0.7)), // More visible border
        color: colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                'Trạng thái tài khoản',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            SwitchListTile(
              title: Row(
                children: [
                  Icon(
                    _isActive ? Icons.check_circle : Icons.cancel,
                    color: _isActive ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trạng thái',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _isActive ? 'Đang hoạt động' : 'Đã khóa',
                style: TextStyle(
                  color: _isActive ? Colors.green : Colors.red,
                ),
              ),
              value: _isActive,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red.shade100,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
