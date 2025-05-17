import 'dart:async';

import 'package:flutter_ecommerce/models/dto/login_response_dto.dart';
import 'package:flutter_ecommerce/services/token_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthNotifier extends StateNotifier<Account?> {
  // Create a StreamController to broadcast auth state changes
  final StreamController<Account?> _authStateController =
      StreamController<Account?>.broadcast();

  AuthNotifier() : super(null) {
    _loadAccount();
  }

  // Method to expose auth state changes as a stream
  Stream<Account?> authStateChanges() {
    return _authStateController.stream;
  }

  Future<void> _loadAccount() async {
    final accountData = await TokenService().getAccount();
    if (accountData != null) {
      final account = Account(
        id: accountData['_id'] ?? '',
        email: accountData['email'] ?? '',
        fullName: accountData['fullName'] ?? '',
        role: accountData['role'] ?? '',
        avatarUrl: accountData['avatarUrl'] ?? '',
        address: accountData['address'] ?? '',
        phoneNumber: accountData['phoneNumber'] ?? '',
      );
      state = account;
      _authStateController.add(account);
    } else {
      state = null;
      _authStateController.add(null);
    }
  }

  Account? get user => state;

  bool get isAuthenticated => state != null;

  void setAccount(Account account) {
    state = account;
    _authStateController.add(account);
  }

  Future<void> logout() async {
    await TokenService().deleteTokens();
    await TokenService().clearAccount();
    state = null;
    _authStateController.add(null); // Emit null for logged out state
  }

  @override
  void dispose() {
    _authStateController.close(); // Close the stream controller when disposed
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Account?>((ref) {
  return AuthNotifier();
});
