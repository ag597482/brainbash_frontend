import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(apiClient: ref.watch(apiClientProvider));
});

// Auth state
class AuthState {
  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  final UserProfile? user;
  final String? token;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    UserProfile? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._apiClient) : super(const AuthState()) {
    _loadSavedToken();
  }

  final AuthService _authService;
  final ApiClient _apiClient;

  Future<void> _loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _apiClient.setAuthToken(token);
      try {
        final user = await _authService.getProfile();
        state = AuthState(user: user, token: token);
      } catch (_) {
        await prefs.remove('auth_token');
        _apiClient.clearAuthToken();
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email: email, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result.token);
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result.token);
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(apiClientProvider),
  );
});
