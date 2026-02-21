import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_url_provider.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart' show AuthService, kGoogleWebClientIdForBackend;

const _keyAuthToken = 'auth_token';
const _keyAuthUser = 'auth_user';
const _keyIsGuest = 'is_guest';

/// Placeholder user for guest mode. No auth APIs are called for this user.
UserProfile get _guestUser => const UserProfile(
      id: 'guest',
      name: 'Guest',
      email: null,
      avatarUrl: null,
      overallScore: null,
      streak: 0,
      categoryStats: {},
      allResponseTimes: [],
    );

// Web client ID (used for web and as serverClientId for Android)
const _googleWebClientId =
    '299124149695-l9j2u20pfjekin89rg24olrob8kia2cr.apps.googleusercontent.com';

// API client provider — one instance; base URL updated when stored URL loads or changes.
// On Android emulator, localhost is resolved to 10.0.2.2 so the app can reach the host backend.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(baseUrl: defaultBaseUrl);
  ref.listen<String?>(baseUrlProvider, (prev, next) {
    client.setBaseUrl(effectiveBaseUrl(next));
  });
  return client;
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(apiClient: ref.watch(apiClientProvider));
});

// Google Sign-In instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    // For web: use Web client ID
    // For Android: clientId is null (uses SHA-1 + package name from Google Cloud Console)
    clientId: kIsWeb ? _googleWebClientId : null,
    // For Android: serverClientId should be Web client ID (for backend to verify id_token)
    // For web: serverClientId is null
    serverClientId: kIsWeb ? null : _googleWebClientId,
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
    this.isGuest = false,
  });

  final UserProfile? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isGuest;

  /// True when user has a real token and profile (not guest).
  bool get isAuthenticated => token != null && user != null;

  /// True when user can use the app (logged in or guest). Used for routing.
  bool get canAccessApp => isAuthenticated || isGuest;

  AuthState copyWith({
    UserProfile? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isGuest,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._apiClient, this._googleSignIn)
      : super(const AuthState(isLoading: true)) {
    _loadSavedToken();
  }

  final AuthService _authService;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  Future<void> _loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAuthToken);

    if (token == null) {
      final isGuest = prefs.getBool(_keyIsGuest) ?? false;
      if (isGuest) {
        state = AuthState(user: _guestUser, token: null, isLoading: false, isGuest: true);
      } else {
        state = const AuthState(isLoading: false);
      }
      return;
    }

    _apiClient.setAuthToken(token);

    // Prefer saved user so we can show home without calling /auth/me
    final userJson = prefs.getString(_keyAuthUser);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserProfile.fromJson(userMap);
        state = AuthState(user: user, token: token, isLoading: false);
        return;
      } catch (_) {
        // Fall through to getProfile or clear
      }
    }

    try {
      final user = await _authService.getProfile();
      state = AuthState(user: user, token: token, isLoading: false);
      await prefs.setString(_keyAuthUser, jsonEncode(user.toJson()));
    } catch (_) {
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyAuthUser);
      _apiClient.clearAuthToken();
      state = const AuthState(isLoading: false);
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
        // User closed the account picker, or sign-in failed (e.g. wrong SHA-1 on Android)
        state = state.copyWith(
          isLoading: false,
          error: kIsWeb
              ? 'Sign-in cancelled.'
              : 'Sign-in cancelled or failed. On Android, add your app\'s SHA-1 and package name (com.indra.brainbash) to the Android OAuth client in Google Cloud Console.',
        );
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (!kIsWeb && googleAuth.idToken == null && googleAuth.accessToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get credentials from Google. Ensure the Android OAuth client has the correct SHA-1 in Google Cloud Console.',
        );
        return;
      }

      // Send whichever token is available.
      // On mobile, idToken is available. On web, only accessToken is.
      final result = await _authService.googleLogin(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAuthToken, result.token);
      await prefs.setString(_keyAuthUser, jsonEncode(result.user.toJson()));

      await prefs.remove(_keyIsGuest);
      state = AuthState(user: result.user, token: result.token, isGuest: false);
    } catch (e, st) {
      debugPrint('Google sign-in error: $e');
      if (e is DioException && e.response != null) {
        final body = e.response!.data;
        final backendError = body is Map && body['error'] != null
            ? body['error'].toString()
            : e.response!.statusCode.toString();
        debugPrint('[Auth] Backend response (${e.response!.statusCode}): $backendError');
      }
      debugPrint(st.toString());
      String message = e.toString();

      // ApiException: 10 = DEVELOPER_ERROR = SHA-1 or package name mismatch in Google Cloud Console
      if (e is PlatformException &&
          (e.code == 'sign_in_failed' || e.message?.contains('ApiException: 10') == true)) {
        message =
            'Google Sign-In failed (Developer Error). Add this app\'s SHA-1 to the Android OAuth client in Google Cloud Console. '
            'Debug/emulator: use debug keystore SHA-1. Play Store: use the SHA-1 from Play Console → App integrity → App signing key. '
            'Package name must be: com.indra.brainbash';
      } else if (e is DioException) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          final body = e.response?.data;
          final backendError = body is Map && body['error'] != null
              ? body['error'].toString()
              : null;
          message = backendError != null
              ? 'Backend rejected sign-in: $backendError'
              : 'Backend rejected sign-in (401). Set GOOGLE_CLIENT_ID on Railway to: ${kGoogleWebClientIdForBackend}';
        } else if (statusCode == 404) {
          message =
              'Backend endpoint not found (404). Ensure the backend route POST /auth/google is configured and accessible.';
        }
      }
      state = state.copyWith(isLoading: false, error: message);
    }
  }

  /// Enter app without signing in. No auth APIs are called for guest users.
  Future<void> continueAsGuest() async {
    state = AuthState(user: _guestUser, token: null, isLoading: false, isGuest: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, true);
  }

  Future<void> logout() async {
    _authService.logout();
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyAuthUser);
    await prefs.remove(_keyIsGuest);
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
