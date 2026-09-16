import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';

/// Ways out of the app to a person or a page: support email, problem reports,
/// and the legal pages the dashboard serves.
abstract final class Support {
  /// Opens a web page in an in-app browser sheet, so reading the terms does
  /// not throw the user out to Safari and leave them to find their way back.
  static Future<void> openPage(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context);

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    ).catchError((_) => false);

    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(l10n.couldNotOpenPage)));
    }
  }

  static Future<void> contactSupport(BuildContext context) =>
      _email(context, subject: AppLocalizations.of(context).appName);

  /// A support email with what we need to reproduce a problem already filled
  /// in underneath — version, platform, language — so nobody has to be asked
  /// "which phone?" in a second email.
  static Future<void> reportProblem(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final info = await PackageInfo.fromPlatform();

    final platform = kIsWeb
        ? 'web'
        : '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

    if (!context.mounted) return;
    await _email(
      context,
      subject: '${l10n.appName} — ${l10n.reportProblemSubject}',
      body: '\n\n\n—\n'
          'App ${info.version} (${info.buildNumber})\n'
          '$platform\n'
          'Language: $locale',
    );
  }

  static Future<void> _email(
    BuildContext context, {
    required String subject,
    String? body,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = AppLocalizations.of(context);

    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      // Uri.queryParameters would encode spaces as `+`, which mail apps show
      // literally.
      query: [
        'subject=${Uri.encodeComponent(subject)}',
        if (body != null) 'body=${Uri.encodeComponent(body)}',
      ].join('&'),
    );

    final opened = await launchUrl(uri).catchError((_) => false);
    if (opened) return;

    // No mail app — common on simulators and on phones that only use webmail.
    // The address is still useful, so hand it over rather than fail silently.
    await Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.noEmailApp(AppConfig.supportEmail))),
    );
  }

  /// The installed version, for the About section.
  static Future<String> version() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}
