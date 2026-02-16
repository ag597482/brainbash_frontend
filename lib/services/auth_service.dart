import 'api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  AuthService({required this.apiClient});

  final ApiClient apiClient;

  Future<({String token, UserProfile user})> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    final token = data['token'] as String;
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    apiClient.setAuthToken(token);
    return (token: token, user: user);
  }

  Future<({String token, UserProfile user})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    final data = response.data!;
    final token = data['token'] as String;
    final user = UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    apiClient.setAuthToken(token);
    return (token: token, user: user);
  }

  Future<UserProfile> getProfile() async {
    final response = await apiClient.get<Map<String, dynamic>>('/auth/profile');
    return UserProfile.fromJson(response.data!);
  }

  void logout() {
    apiClient.clearAuthToken();
  }
}
