import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8080/api/auth'));

  // Login: POST /login with {email, password}
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw Exception(response.data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register: POST /register with {fullName, phone, email, password}
  Future<bool> register(String fullName, String phone, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        // For testing, print the OTP returned
        print("OTP sent: ${response.data['otp']}");
        return true;
      } else {
        throw Exception(response.data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Verify OTP: POST /verify-otp with {email, otp}
  Future<String> verifyOTP(String email, String otp) async {
    try {
      final response = await _dio.post('/verify-otp', data: {
        'email': email,
        'otp': otp,
      });
      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw Exception(response.data['error'] ?? 'OTP Verification failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
