import 'package:dio/dio.dart';
import 'package:invoice/data/models/user.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<User> login({required String email, required String password}) async {
    try {
      print('email: $email, password: $password');
      final Response response = await _apiService.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true && data['user'] == null) {
        throw Exception("Invalid response");
      }

      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioError catch (e) {
      final msg =
          e.response?.data is Map<String, dynamic>
              ? (e.response!.data['detail']?.toString()) ?? "Login failed"
              : "Login failed";
      throw Exception(msg);
    }
  }
}
