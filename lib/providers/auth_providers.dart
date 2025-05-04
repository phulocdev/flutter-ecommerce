import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = await TokenService().getUser();
    if (userData != null) {
      state = User(
        email: userData['email'] ?? '',
        fullName: userData['fullName'] ?? '',
        role: userData['role'] ?? '',
      );
    } else {
      state = null;
    }
  }

  User? get user => state;

  bool get isAuthenticated => state != null;

  void setUser(User user) {
    state = user;
  }

  Future<void> logout() async {
    await TokenService().deleteTokens();
    await TokenService().clearUser();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
