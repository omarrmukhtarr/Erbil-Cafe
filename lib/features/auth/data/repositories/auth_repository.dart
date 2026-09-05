import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String locale = 'ku',
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'locale': locale,
      },
    );
    return _persist(json);
  }

  Future<AppUser> login({required String email, required String password}) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _persist(json);
  }

  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    if (refresh != null) {
      // Revoke server-side; clearing local storage alone leaves it valid.
      try {
        await _api.post<void>('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {
        // A failed revoke must not block signing out on this device.
      }
    }
    await _tokens.clear();
  }

  Future<AppUser> me() async {
    final json = await _api.get<Map<String, dynamic>>('/users/me');
    return AppUser.fromJson(json);
  }

  Future<bool> get hasSession => _tokens.hasSession;

  // ─── OTP & password ─────────────────────────────────────────────────

  /// Sends a one-time code. Outside production the API echoes the code back as
  /// `devCode` so the flow can be completed without an SMS provider.
  Future<String?> requestOtp(String identifier, {String purpose = 'PHONE_VERIFY'}) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: {'identifier': identifier, 'purpose': purpose},
    );
    return json['devCode'] as String?;
  }

  Future<void> verifyOtp(
    String identifier,
    String code, {
    String purpose = 'PHONE_VERIFY',
  }) =>
      _api.post<void>(
        '/auth/otp/verify',
        data: {'identifier': identifier, 'code': code, 'purpose': purpose},
      );

  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) =>
      _api.post<void>(
        '/auth/password/reset',
        data: {
          'identifier': identifier,
          'code': code,
          'newPassword': newPassword,
          'purpose': 'PASSWORD_RESET',
        },
      );

  Future<AppUser> updateProfile({String? name, String? phone, String? locale}) async {
    final json = await _api.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (locale != null) 'locale': locale,
      },
    );
    return AppUser.fromJson(json);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _api.patch<void>(
        '/users/me/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

  Future<AppUser> _persist(Map<String, dynamic> json) async {
    await _tokens.saveTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
    return AppUser.fromJson(json['user'] as Map<String, dynamic>);
  }
}
