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
      final registerResponse = response;
      final data = registerResponse.data;

      await _tokenService.saveTokens(data.accessToken, data.refreshToken);
      await _tokenService.saveUser(
        email: data.account.email,
        fullName: data.account.fullName,
        role: data.account.role,
      );

      ref.read(authProvider.notifier).setUser(
            User(
              email: data.account.email,
              fullName: data.account.fullName,
              role: data.account.role,
            ),
          );

      if (mounted) context.go(AppRoute.products.path);
    } on ApiException catch (e) {
      if (mounted) {
        if (e.statusCode == 422 && e.errors != null && e.errors!.isNotEmpty) {
          final fieldError = e.errors!.firstWhere(
            (err) {
              return err['field'] == 'email';
            },
            orElse: () => {},
          );
          setState(() {
            _serverErrorMessage = fieldError['message'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Failed: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Register',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
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
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (value) => _email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
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
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (value) => _fullName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.length < 8) {
                        return 'Please enter at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
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
                    ),
                    onSaved: (value) => _address = value,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      if (value.length < 8) {
                        return 'Please enter at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: _toggleShowPassword,
                        icon: Icon(_hiddenPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
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
                    ),
                    obscureText: _hiddenPassword,
                    onSaved: (value) => _password = value,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 8)
                        return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
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
                    onPressed: () {
                      if (!_isLoading) {
                        _handleRegistration();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sign Up',
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
                  if (_serverErrorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _serverErrorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoute.login.path);
                        },
                        child: const Text('Log in'),
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
}
