/// Spacing scale on a 4pt grid.
///
/// v1 sized everything against a fixed 375×812 design and scaled it per
/// device, which stretched text on tablets. Fixed spacing plus responsive
/// layout behaves better across screen sizes.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 48.0;

  /// Standard horizontal page padding.
  static const page = 20.0;
}
