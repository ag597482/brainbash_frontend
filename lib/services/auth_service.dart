import 'api_client.dart';
import '../models/user_profile.dart';

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
