import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/models/dto/register_request_dto.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  final _tokenService = TokenService();
  late final AuthApiService _authApiService =
      AuthApiService(_apiClient, _tokenService);

  String? _email, _fullName, _address, _password;
  bool _isLoading = false;
  bool _hiddenPassword = true;

  String? _serverErrorMessage;

  void _toggleShowPassword() {
    setState(() {
      _hiddenPassword = !_hiddenPassword;
    });
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _serverErrorMessage = null;
    });

    final registerDto = RegisterRequestDto(
      email: _email!,
      fullName: _fullName!,
      address: _address!,
      password: _password!,
    );

    try {
      final response = await _authApiService.register(registerDto);
      final data = response.data;
      final account = data.account;

      await _tokenService.saveTokens(data.accessToken, data.refreshToken);
      await _tokenService.saveAccount(account);

      ref.read(authProvider.notifier).setAccount(account);

      if (mounted) context.go(AppRoute.home.path);
    } on ApiException catch (e) {
      if (mounted) {
        if (e.statusCode == 422 && e.errors != null && e.errors!.isNotEmpty) {
          final fieldError = e.errors!.firstWhere(
            (err) => err['field'] == 'email',
            orElse: () => {},
          );
          setState(() {
            _serverErrorMessage = fieldError['message'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký thất bại: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Đăng ký',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
        ),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Container(
                  width: isWideScreen ? 500 : double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Tạo tài khoản',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildFullNameField(),
                        const SizedBox(height: 16),
                        _buildAddressField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        _buildRegisterButton(),
                        if (_serverErrorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _serverErrorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _buildLoginNavigation(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: _inputDecoration(label: 'Email', icon: Icons.email),
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (value) => _email = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      decoration: _inputDecoration(label: 'Họ và tên', icon: Icons.person),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (value) => _fullName = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập họ tên';
        if (value.length < 8) return 'Họ tên phải có ít nhất 8 ký tự';
        return null;
      },
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      decoration: _inputDecoration(label: 'Địa chỉ', icon: Icons.location_on),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: (value) => _address = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập địa chỉ';
        if (value.length < 8) return 'Địa chỉ phải có ít nhất 8 ký tự';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: _inputDecoration(
        label: 'Mật khẩu',
        icon: Icons.lock,
        suffixIcon: IconButton(
          onPressed: _toggleShowPassword,
          icon: Icon(
            _hiddenPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
        ),
      ),
      obscureText: _hiddenPassword,
      onSaved: (value) => _password = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
        if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: _isLoading ? null : _handleRegistration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Đăng ký',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          if (_isLoading) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bạn đã có tài khoản?'),
        TextButton(
          onPressed: () {
            context.go(AppRoute.login.path);
          },
          child: const Text('Đăng nhập'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }
}
