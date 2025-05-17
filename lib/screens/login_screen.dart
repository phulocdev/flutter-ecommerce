import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/auth_api_service.dart';
import 'package:flutter_ecommerce/models/dto/login_request_dto.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';
import 'package:flutter_ecommerce/services/api_client.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();
  final _tokenService = TokenService();
  late final AuthApiService _authApiService =
      AuthApiService(_apiClient, _tokenService);
  String? _email, _password;
  bool _isLoading = false;
  bool _hiddenPassword = true;

  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoute.home.path);
      });
    }
  }

  void _toggleShowPassword() {
    setState(() {
      _hiddenPassword = !_hiddenPassword;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _serverErrorMessage = null;
    });

    final loginDto = LoginRequestDto(email: _email!, password: _password!);

    try {
      final response = await _authApiService.login(loginDto);
      final data = response.data;
      final account = data.account;

      await _tokenService.saveTokens(data.accessToken, data.refreshToken);
      await _tokenService.saveAccount(account);

      ref.read(authProvider.notifier).setAccount(account);

      if (mounted) context.go(AppRoute.home.path);
    } catch (e) {
      if (mounted) {
        if (e is ApiException &&
            e.statusCode == 422 &&
            e.errors != null &&
            e.errors!.isNotEmpty) {
          final fieldError = e.errors!.firstWhere(
            (err) => err['field'] == 'password',
            orElse: () => {},
          );
          setState(() {
            _serverErrorMessage = fieldError['message'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập thất bại: $e')),
          );
        }
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Đăng nhập',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Chào mừng bạn quay trở lại!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Nhập email của bạn',
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.black),
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (value) => _email = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Vui lòng nhập đúng định dạng email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: _toggleShowPassword,
                          icon: Icon(
                            _hiddenPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                        ),
                        hintStyle: const TextStyle(color: Colors.black),
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      obscureText: _hiddenPassword,
                      autofillHints: const [AutofillHints.password],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (value) => _password = value,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Vui lòng nhập mật khẩu';
                        if (value.length < 6)
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                    if (_serverErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _serverErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Đăng nhập',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          if (_isLoading) ...[
                            const SizedBox(width: 12),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.push(AppRoute.forgotPassword.path),
                      child: const Text('Quên mật khẩu?'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có tài khoản? "),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => context.push(AppRoute.register.path),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
