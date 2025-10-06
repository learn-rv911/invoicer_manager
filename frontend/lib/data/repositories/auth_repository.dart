import '../models/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<User> login({required String email, required String password}) {
    return _authService.login(email: email, password: password);
  }
}
