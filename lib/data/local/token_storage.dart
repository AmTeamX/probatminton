import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _expiresAtKey = 'expires_at';

  final FlutterSecureStorage _secureStorage;

  TokenStorage(this._secureStorage);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<bool> isTokenValid() async {
    final expiresAtStr = await _secureStorage.read(key: _expiresAtKey);
    if (expiresAtStr == null) return false;
    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiresAt * 1000;
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresAtKey);
  }

  Future<String?> refreshToken() async {
    // Implement token refresh if backend supports it
    // Otherwise return null to trigger re-login
    return null;
  }
}
