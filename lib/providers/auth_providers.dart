import 'dart:async';

import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthNotifier extends StateNotifier<User?> {
  // Create a StreamController to broadcast auth state changes
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  AuthNotifier() : super(null) {
    _loadUser();
  }

  // Method to expose auth state changes as a stream
  Stream<User?> authStateChanges() {
    return _authStateController.stream;
  }

  Future<void> _loadUser() async {
    final userData = await TokenService().getUser();
    if (userData != null) {
      final user = User(
        id: userData['_id'] ?? '',
        email: userData['email'] ?? '',
        fullName: userData['fullName'] ?? '',
        role: userData['role'] ?? '',
      );
      state = user;
      _authStateController.add(user); // Emit the loaded user
    } else {
      state = null;
      _authStateController.add(null); // Emit null for logged out state
    }
  }

  User? get user => state;

  bool get isAuthenticated => state != null;

  void setUser(User user) {
    state = user;
    _authStateController.add(user); // Emit the new user
  }

  Future<void> logout() async {
    await TokenService().deleteTokens();
    await TokenService().clearUser();
    state = null;
    _authStateController.add(null); // Emit null for logged out state
  }

  @override
  void dispose() {
    _authStateController.close(); // Close the stream controller when disposed
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
