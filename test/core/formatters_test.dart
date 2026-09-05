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

  group('relative', () {
    test('describes recent times', () {
      final now = DateTime.now();
      expect(Formatters.relative(now), 'just now');
      expect(
        Formatters.relative(now.subtract(const Duration(minutes: 5))),
        '5m ago',
      );
      expect(
        Formatters.relative(now.subtract(const Duration(hours: 3))),
        '3h ago',
      );
      expect(
        Formatters.relative(now.subtract(const Duration(days: 2))),
        '2d ago',
      );
    });

    test('rolls up to months and years', () {
      final now = DateTime.now();
      expect(
        Formatters.relative(now.subtract(const Duration(days: 60))),
        '2mo ago',
      );
      expect(
        Formatters.relative(now.subtract(const Duration(days: 400))),
        '1y ago',
      );
    });
  });
}
