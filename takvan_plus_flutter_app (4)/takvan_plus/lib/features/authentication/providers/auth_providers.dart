import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  const AuthState({this.status = AuthStatus.unknown, this.user});
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState()) {
    _bootstrap();
  }

  final _storage = const FlutterSecureStorage();
  final Dio _dio = ApiClient.instance.dio;

  Future<void> _bootstrap() async {
    final token = await _storage.read(key: 'access_token');
    state = AuthState(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  /// Step 1: request an OTP code be sent to [phone].
  Future<void> requestOtp(String phone) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }
    await _dio.post('/auth/otp/request', data: {'phone': phone});
  }

  /// Step 2: verify the code and, on success, persist tokens + user.
  Future<bool> verifyOtp(String phone, String code) async {
    if (AppConfig.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      await _storage.write(key: 'access_token', value: 'mock_access_token');
      await _storage.write(key: 'refresh_token', value: 'mock_refresh_token');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(id: 'mock-user', phoneNumber: phone, isPhoneVerified: true),
      );
      return true;
    }
    try {
      final res = await _dio.post('/auth/otp/verify', data: {'phone': phone, 'code': code});
      final data = res.data as Map<String, dynamic>;
      await _storage.write(key: 'access_token', value: data['accessToken'] as String);
      await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
