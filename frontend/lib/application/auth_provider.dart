import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:invoice/data/models/user.dart';

import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({User? user, bool? loading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(AuthState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = AuthState(user: null, loading: false, error: e.toString());
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.read(apiServiceProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(authServiceProvider)));
final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref.read(authRepositoryProvider)));

