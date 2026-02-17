import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

const _googleClientId =
    '299124149695-l9j2u20pfjekin89rg24olrob8kia2cr.apps.googleusercontent.com';

// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(apiClient: ref.watch(apiClientProvider));
});

// Google Sign-In instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: kIsWeb ? _googleClientId : null,
    serverClientId: kIsWeb ? null : _googleClientId,
    scopes: ['email', 'profile'],
  );
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
  AuthNotifier(this._authService, this._apiClient, this._googleSignIn)
      : super(const AuthState()) {
    _loadSavedToken();
  }

  final AuthService _authService;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

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

  /// Google Sign-In flow that works on both web and mobile:
  /// - Mobile: signIn() returns an id_token -> sent to backend
  /// - Web: signIn() returns an access_token -> sent to backend
  /// The backend handles both token types.
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      // Send whichever token is available.
      // On mobile, idToken is available. On web, only accessToken is.
      final result = await _authService.googleLogin(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
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
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(apiClientProvider),
    ref.watch(googleSignInProvider),
  );
});
