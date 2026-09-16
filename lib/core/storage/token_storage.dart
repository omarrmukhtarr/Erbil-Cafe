import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists auth tokens in the platform keystore.
///
/// Tokens go to the iOS Keychain and Android EncryptedSharedPreferences rather
/// than SharedPreferences, which is plain text and readable on a rooted device.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'erbilcafe.access_token';
  static const _refreshKey = 'erbilcafe.refresh_token';
  static const _userKey = 'erbilcafe.user';

  /// Cached in memory so the common path does not hit the keystore on every
  /// request — secure storage reads cross a platform channel.
  String? _cachedAccess;

  Future<String?> readAccessToken() async {
    return _cachedAccess ??= await _storage.read(key: _accessKey);
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccess = accessToken;
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  /// The signed-in user's profile as the API last returned it.
  ///
  /// Kept beside the tokens (not in SharedPreferences) because it holds an
  /// email address and a phone number.
  Future<String?> readUser() => _storage.read(key: _userKey);

  Future<void> saveUser(String json) =>
      _storage.write(key: _userKey, value: json);

  Future<void> clear() async {
    _cachedAccess = null;
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
      _storage.delete(key: _userKey),
    ]);
  }

  Future<bool> get hasSession async => await readRefreshToken() != null;
}
