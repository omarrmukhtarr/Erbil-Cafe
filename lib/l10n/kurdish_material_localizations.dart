import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Material and Cupertino strings for Kurdish.
///
/// Flutter's own `GlobalMaterialLocalizations` has no `ku` entry, so without
/// this every framework-supplied string — date picker headings, dialog
/// buttons, the text-selection menu, semantics labels — silently falls back to
/// English **and to left-to-right**, inside an otherwise Kurdish RTL app.
///
/// Arabic is used as the base: it is the closest supported locale that shares
/// Sorani's script and direction, so pickers and menus at least read correctly
/// rather than flipping to English.
abstract final class KurdishLocalizations {
  static const _base = Locale('ar');

  static const delegates = <LocalizationsDelegate<dynamic>>[
    _KuMaterialDelegate(),
    _KuCupertinoDelegate(),
    _KuWidgetsDelegate(),
  ];
}

class _KuMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _KuMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(KurdishLocalizations._base);

  @override
  bool shouldReload(_) => false;
}

class _KuCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KuCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(KurdishLocalizations._base);

  @override
  bool shouldReload(_) => false;
}

class _KuWidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _KuWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  /// This is also what gives Kurdish its right-to-left direction, which
  /// Flutter's own table does not assign to `ku`.
  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(KurdishLocalizations._base);

  @override
  bool shouldReload(_) => false;
}
