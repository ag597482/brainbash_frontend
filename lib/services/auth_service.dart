import 'package:flutter/foundation.dart';

import 'api_client.dart';
import '../models/user_profile.dart';

/// Google OAuth Web client ID — backend must verify id_token with this client.
/// Used only for debug message when backend returns 401.
const String kGoogleWebClientIdForBackend =
    '299124149695-l9j2u20pfjekin89rg24olrob8kia2cr.apps.googleusercontent.com';

class AuthService {
  AuthService({required this.apiClient});

  final ApiClient apiClient;

  /// Sends either an id_token or access_token to the backend for verification.
  /// On mobile, Google Sign-In provides an id_token.
  /// On web, it provides an access_token instead.
  Future<({String token, UserProfile user})> googleLogin({
    String? idToken,
    String? accessToken,
  }) async {
    final data = <String, dynamic>{};
    if (idToken != null) data['id_token'] = idToken;
    if (accessToken != null) data['access_token'] = accessToken;

    if (kDebugMode) {
      final baseUrl = apiClient.dio.options.baseUrl;
      debugPrint(
        '[Auth] POST $baseUrl/auth/google with '
        'id_token: ${idToken != null ? "${idToken.length} chars" : "null"}, '
        'access_token: ${accessToken != null ? "${accessToken.length} chars" : "null"}',
      );
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/google',
      data: data,
    );
    final responseData = response.data!;
    final token = responseData['access_token'] as String;
    final user =
        UserProfile.fromJson(responseData['user'] as Map<String, dynamic>);
    apiClient.setAuthToken(token);
    return (token: token, user: user);
  }

  /// Fetches the current authenticated user's profile from the backend.
  Future<UserProfile> getProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>('/auth/me');
    return UserProfile.fromJson(response.data!);
  }

  void logout() {
    apiClient.clearAuthToken();
  }
}
