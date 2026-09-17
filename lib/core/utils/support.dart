import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
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

  /// A correction for one café, with the café named in the subject and its
  /// page linked in the body, so nobody has to ask which one.
  static Future<void> reportCafe(
    BuildContext context, {
    required String name,
    required String slug,
  }) {
    final l10n = AppLocalizations.of(context);
    return _email(
      context,
      subject: l10n.wrongInfoSubject(name),
      body: '\n\n\n—\n${AppConfig.cafePageUrl(slug)}',
    );
  }

  /// The system share sheet for a café.
  ///
  /// [origin] is the button's box: an iPad anchors the share popover to it,
  /// and without one the sheet cannot open there at all.
  static Future<void> shareCafe(
    BuildContext context, {
    required String name,
    required String slug,
  }) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: l10n.shareCafeMessage(name, AppConfig.cafePageUrl(slug)),
        subject: name,
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

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
