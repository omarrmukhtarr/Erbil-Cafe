import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

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

  /// How long ago, in the reader's language: "5 minutes ago", "Yesterday",
  /// and a plain date once it is more than a week old.
  ///
  /// This replaced an English-only `relative()` that printed "3d ago" under
  /// every review, whatever language the rest of the page was in.
  static String ago(DateTime value, AppLocalizations l10n, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(value);

    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inHours < 1) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);

    // intl has no Kurdish date symbols; Arabic is the fallback the rest of
    // the app's Kurdish framework strings already use.
    final locale = DateFormat.localeExists(l10n.localeName) ? l10n.localeName : 'ar';
    return DateFormat.yMMMd(locale).format(value);
  }
}
