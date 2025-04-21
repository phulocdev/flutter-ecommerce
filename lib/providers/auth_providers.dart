import 'package:flutter/material.dart';
import '../services/token_service.dart';

class User {
  final String email;
  final String fullName;
  final String role;

  User({required this.email, required this.fullName, required this.role});
}

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = await TokenService().getUser();
    if (userData != null) {
      _user = User(
          email: userData['email'] ?? '',
          fullName: userData['fullName'] ?? '',
          role: userData['role'] ?? '');
    } else {
      _user = null;
    }
  }

  bool get isAuthenticated => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
