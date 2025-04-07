import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8080/api'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> sendOtp(String email) async {
    await _dio.post('/auth/request-otp', data: {'email': email});
  }

  Future<String> verifyOtp(String email, String otp) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
    });

    final token = response.data['token'];
    await _storage.write(key: 'jwt_token', value: token);
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}
