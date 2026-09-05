import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _thousands = NumberFormat('#,###');

  /// Iraqi dinar, e.g. `IQD 5,000`.
  ///
  /// v1 wrote `"\IQD\t"` before the number — an escaped `I` and a literal tab —
  /// which rendered inconsistently. The currency label is passed in so it can
  /// be localised (`د.ع` in Kurdish and Arabic).
  static String price(int amountIqd, String currencyLabel) =>
      '$currencyLabel ${_thousands.format(amountIqd)}';

  static String date(DateTime value, [String? locale]) =>
      DateFormat.yMMMd(locale).format(value);

  static String dateTime(DateTime value, [String? locale]) =>
      DateFormat.yMMMd(locale).add_Hm().format(value);

  static String monthDay(DateTime value, [String? locale]) =>
      DateFormat.MMMd(locale).format(value);

  /// Coarse relative time for review timestamps.
  static String relative(DateTime value) {
    final diff = DateTime.now().difference(value);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
