import 'package:finance_manager_app/pages/Login%20page/authservice.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? token;
  bool loading = false;
  String? errorMessage;

  // Login: if account exists and password is correct, return token.
  Future<bool> login(String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _authService.login(email, password);
      token = res;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  // Register: send registration data; OTP is sent from the backend.
  Future<bool> register(
      String fullName, String phone, String email, String password) async {
    loading = true;
    notifyListeners();
    try {
      bool res = await _authService.register(fullName, phone, email, password);
      loading = false;
      notifyListeners();
      return res;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP: upon success, a token is returned.
  Future<bool> verifyOTP(String email, String otp) async {
    loading = true;
    notifyListeners();
    try {
      final res = await _authService.verifyOTP(email, otp);
      token = res;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    token = null;
    notifyListeners();
  }
}
