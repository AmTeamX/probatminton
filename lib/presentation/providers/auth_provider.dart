import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';
import '../../data/local/token_storage.dart';
import '../../data/remote/api/auth_api.dart';
import '../../domain/models/user.dart';

// Token storage provider
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(baseUrl: ApiConfig.baseUrl, tokenStorage: tokenStorage);
});

// Auth API provider
final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient.dio);
});

// Auth status sealed class
sealed class AuthStatus {
  const AuthStatus();
}

class Authenticated extends AuthStatus {
  final UserProfile user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthStatus {
  const Unauthenticated();
}

class AuthLoading extends AuthStatus {
  const AuthLoading();
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<AuthStatus>> {
  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._authApi, this._tokenStorage)
    : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final isValid = await _tokenStorage.isTokenValid();
      if (isValid) {
        final response = await _authApi.getProfile();
        dynamic data = response.data;
        if (data is String) data = jsonDecode(data);
        if (data is Map && data['profile'] != null) {
          final user = UserProfile.fromJson(
            Map<String, dynamic>.from(data['profile'] as Map),
          );
          state = AsyncValue.data(Authenticated(user));
        } else {
          // Token invalid or profile fetch failed
          await _tokenStorage.clearTokens();
          state = const AsyncValue.data(Unauthenticated());
        }
      } else {
        state = const AsyncValue.data(Unauthenticated());
      }
    } catch (e) {
      state = const AsyncValue.data(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authApi.login({
        'email': email,
        'password': password,
      });
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      if (data == null || data is! Map || data['session'] == null) {
        throw Exception('Invalid login response: missing session data');
      }
      final session = Map<String, dynamic>.from(data['session'] as Map);
      await _tokenStorage.saveTokens(
        accessToken: session['access_token']?.toString() ?? '',
        refreshToken: session['refresh_token']?.toString() ?? '',
        expiresAt: session['expires_at'] is int
            ? session['expires_at'] as int
            : int.tryParse(session['expires_at']?.toString() ?? '') ?? 0,
      );
      final profile = await _authApi.getProfile();
      dynamic profileData = profile.data;
      if (profileData is String) profileData = jsonDecode(profileData);
      if (profileData == null ||
          profileData is! Map ||
          profileData['profile'] == null) {
        throw Exception('Invalid profile response: missing profile data');
      }
      final user = UserProfile.fromJson(
        Map<String, dynamic>.from(profileData['profile'] as Map),
      );
      state = AsyncValue.data(Authenticated(user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(Map<String, dynamic> body) async {
    state = const AsyncValue.loading();
    try {
      await _authApi.register(body);
      // Auto-login after registration
      final loginResponse = await _authApi.login({
        'email': body['email'],
        'password': body['password'],
      });
      dynamic loginData = loginResponse.data;
      if (loginData is String) loginData = jsonDecode(loginData);
      final session = loginData['session'];
      await _tokenStorage.saveTokens(
        accessToken: session['access_token']?.toString() ?? '',
        refreshToken: session['refresh_token']?.toString() ?? '',
        expiresAt: session['expires_at'] is int
            ? session['expires_at'] as int
            : int.tryParse(session['expires_at']?.toString() ?? '') ?? 0,
      );
      final profile = await _authApi.getProfile();
      dynamic profileData = profile.data;
      if (profileData is String) profileData = jsonDecode(profileData);
      if (profileData == null ||
          profileData is! Map ||
          profileData['profile'] == null) {
        throw Exception('Invalid profile response: missing profile data');
      }
      final user = UserProfile.fromJson(
        Map<String, dynamic>.from(profileData['profile'] as Map),
      );
      state = AsyncValue.data(Authenticated(user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    state = const AsyncValue.data(Unauthenticated());
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      await _authApi.updateProfile({
        'full_name': fullName,
        'email': email,
        'phone': ?phone,
        'address': ?address,
      });
      await refreshProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _authApi.getProfile();
      dynamic data = profile.data;
      if (data is String) data = jsonDecode(data);
      if (data is Map && data['profile'] != null) {
        final user = UserProfile.fromJson(
          Map<String, dynamic>.from(data['profile'] as Map),
        );
        state = AsyncValue.data(Authenticated(user));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthStatus>>((ref) {
      final authApi = ref.watch(authApiProvider);
      final tokenStorage = ref.watch(tokenStorageProvider);
      return AuthNotifier(authApi, tokenStorage);
    });
