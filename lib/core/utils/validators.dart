import '../../l10n/app_localizations.dart';

/// Form validation, localised.
///
/// v1 kept these as global constants in `constants.dart` with English-only
/// messages and a regex that accepted `a@b.c` but rejected `a+b@c.com`.
abstract final class Validators {
  /// Deliberately permissive: the API is the authority on deliverability, and
  /// an over-strict client regex rejects valid addresses.
  static final _emailPattern = RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$');

  /// International format, 8–15 digits after the country code.
  static final _phonePattern = RegExp(r'^\+?[1-9]\d{7,14}$');

  static String? email(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.emailRequired;
    if (!_emailPattern.hasMatch(trimmed)) return l10n.emailInvalid;
    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 8) return l10n.passwordTooShort;
    // Matches the API's rule, so the server cannot reject what the form accepted.
    if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return l10n.passwordNeedsLetterAndNumber;
    }
    return null;
  }

  static String? confirmPassword(
    String? value,
    String original,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value != original) return l10n.passwordsDoNotMatch;
    return null;
  }

  static String? name(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < 2) return l10n.nameRequired;
    return null;
  }

  static String? phone(String? value, AppLocalizations l10n, {bool required = true}) {
    final trimmed = value?.trim().replaceAll(' ', '') ?? '';
    if (trimmed.isEmpty) return required ? l10n.phoneRequired : null;
    if (!_phonePattern.hasMatch(trimmed)) return l10n.phoneInvalid;
    return null;
  }
}
