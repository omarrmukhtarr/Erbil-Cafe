import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/widgets.dart';
import 'package:erbilcafe/l10n/app_localizations.dart';
import 'package:erbilcafe/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('price', () {
    test('groups thousands and puts the currency first', () {
      // v1 wrote "\IQD\t" before the number — an escaped I and a literal tab.
      expect(Formatters.price(5000, 'IQD'), 'IQD 5,000');
      expect(Formatters.price(3000, 'IQD'), 'IQD 3,000');
    });

    test('handles values below and above the grouping boundary', () {
      expect(Formatters.price(500, 'IQD'), 'IQD 500');
      expect(Formatters.price(1250000, 'IQD'), 'IQD 1,250,000');
      expect(Formatters.price(0, 'IQD'), 'IQD 0');
    });

    test('takes the currency label from the caller so it can be localised', () {
      expect(Formatters.price(4000, 'د.ع'), 'د.ع 4,000');
    });
  });

  group('ago', () {
    // In the app, flutter_localizations loads date symbols; a unit test has
    // to ask for them itself.
    setUpAll(initializeDateFormatting);
    final en = lookupAppLocalizations(const Locale('en'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    final now = DateTime(2026, 9, 17, 12);

    test('describes recent times in words', () {
      expect(Formatters.ago(now, en, now: now), 'Just now');
      expect(
        Formatters.ago(now.subtract(const Duration(minutes: 5)), en, now: now),
        '5 minutes ago',
      );
      expect(
        Formatters.ago(now.subtract(const Duration(hours: 1)), en, now: now),
        '1 hour ago',
      );
      expect(
        Formatters.ago(now.subtract(const Duration(days: 1)), en, now: now),
        'Yesterday',
      );
    });

    test('switches to a date after a week', () {
      expect(
        Formatters.ago(DateTime(2026, 8, 1), en, now: now),
        'Aug 1, 2026',
      );
    });

    test('speaks the reader\'s language', () {
      expect(Formatters.ago(now, ar, now: now), 'الآن');
      final ku = lookupAppLocalizations(const Locale('ku'));
      expect(
        Formatters.ago(now.subtract(const Duration(days: 3)), ku, now: now),
        '3 ڕۆژ لەمەوبەر',
      );
      // No Kurdish date symbols in intl: falls back rather than throwing.
      expect(() => Formatters.ago(DateTime(2026, 1, 1), ku, now: now),
          returnsNormally);
    });
  });
}
