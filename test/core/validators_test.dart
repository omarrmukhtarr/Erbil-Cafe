import 'package:erbilcafe/core/utils/validators.dart';
import 'package:erbilcafe/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The English bundle is enough: these tests assert which rule fires, not the
  // wording, and the messages come from the same ARB keys in every locale.
  final l10n = AppLocalizationsEn();

  group('email', () {
    test('accepts ordinary addresses', () {
      expect(Validators.email('omer@example.com', l10n), isNull);
      expect(Validators.email('omer.mukhtar@erbilcafe.app', l10n), isNull);
    });

    test('accepts plus addressing, which v1 rejected', () {
      // v1's regex was ^[a-zA-Z0-9.]+@… so a '+' failed a valid address.
      expect(Validators.email('omer+cafe@example.com', l10n), isNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('omer', l10n), isNotNull);
      expect(Validators.email('omer@', l10n), isNotNull);
      expect(Validators.email('omer@example', l10n), isNotNull);
      expect(Validators.email('@example.com', l10n), isNotNull);
    });

    test('requires a value', () {
      expect(Validators.email('', l10n), l10n.emailRequired);
      expect(Validators.email(null, l10n), l10n.emailRequired);
    });

    test('ignores surrounding whitespace', () {
      expect(Validators.email('  omer@example.com  ', l10n), isNull);
    });
  });

  group('password', () {
    test('accepts a letter-and-digit password of at least 8', () {
      expect(Validators.password('coffee2026', l10n), isNull);
    });

    test('rejects short passwords', () {
      expect(Validators.password('cof123', l10n), l10n.passwordTooShort);
    });

    test('mirrors the API rule requiring a letter and a number', () {
      // If the client were laxer, the server would reject what the form accepted.
      expect(
        Validators.password('coffeecoffee', l10n),
        l10n.passwordNeedsLetterAndNumber,
      );
      expect(
        Validators.password('12345678', l10n),
        l10n.passwordNeedsLetterAndNumber,
      );
    });
  });

  group('confirmPassword', () {
    test('must match', () {
      expect(Validators.confirmPassword('a1bcdefg', 'a1bcdefg', l10n), isNull);
      expect(
        Validators.confirmPassword('a1bcdefg', 'different', l10n),
        l10n.passwordsDoNotMatch,
      );
    });
  });

  group('phone', () {
    test('accepts international format', () {
      expect(Validators.phone('+9647501234567', l10n), isNull);
      expect(Validators.phone('9647501234567', l10n), isNull);
    });

    test('tolerates spaces as typed', () {
      expect(Validators.phone('+964 750 123 4567', l10n), isNull);
    });

    test('rejects a leading zero after the plus and short numbers', () {
      expect(Validators.phone('+0647501234567', l10n), l10n.phoneInvalid);
      expect(Validators.phone('12345', l10n), l10n.phoneInvalid);
    });

    test('is optional when not required', () {
      expect(Validators.phone('', l10n, required: false), isNull);
      expect(Validators.phone('', l10n), l10n.phoneRequired);
    });
  });
}
