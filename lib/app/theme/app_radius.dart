import 'package:flutter/widgets.dart';

/// The radius scale, taken from v1's actual usage.
///
/// v1 used 20 most often (11 occurrences of `circular(20.0)` plus 10 of
/// `circular(20)`), then 10, then 25/50 for pills. These names replace the
/// scattered literals.
abstract final class AppRadius {
  /// Chips, small tiles, thumbnails.
  static const chip = 10.0;

  /// Text fields and secondary buttons.
  static const input = 15.0;

  /// Cards — the dominant radius in the app.
  static const card = 20.0;

  /// Pills and avatars.
  static const pill = 25.0;

  /// Bottom sheets and large panels.
  static const sheet = 30.0;

  static const chipR = BorderRadius.all(Radius.circular(chip));
  static const inputR = BorderRadius.all(Radius.circular(input));
  static const cardR = BorderRadius.all(Radius.circular(card));
  static const pillR = BorderRadius.all(Radius.circular(999));

  /// Sheets round only their top corners.
  static const sheetR = BorderRadius.vertical(top: Radius.circular(sheet));
}
