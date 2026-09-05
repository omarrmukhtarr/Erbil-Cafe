import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = AppSettings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text(l10n.language, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _Options<Locale?>(
            value: settings.locale,
            // Null follows the device language.
            options: const [
              (null, 'System'),
              (Locale('ku'), 'کوردی'),
              (Locale('ar'), 'العربية'),
              (Locale('en'), 'English'),
            ],
            onChanged: (locale) async {
              await settings.setLocale(locale);
              // Persist the choice on the account too, so notifications arrive
              // in the same language on every device.
              if (locale != null && context.mounted) {
                await context
                    .read<AuthCubit>()
                    .updateProfile(locale: locale.languageCode);
              }
            },
          ),

          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.theme, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _Options<ThemeMode>(
            value: settings.themeMode,
            options: [
              (ThemeMode.dark, l10n.themeDark),
              (ThemeMode.light, l10n.themeLight),
              (ThemeMode.system, l10n.themeSystem),
            ],
            onChanged: settings.setThemeMode,
          ),

          const SizedBox(height: AppSpacing.xxl),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.aboutApp, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.appName} · v2.0.0\n${l10n.appTagline}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// A radio group rendered as pills, matching the app's chip style.
class _Options<T> extends StatelessWidget {
  const _Options({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<(T, String)> options;
  final Future<void> Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (optionValue, label) in options)
          Material(
            color: optionValue == value
                ? AppColors.accent
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.pillR,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onChanged(optionValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: optionValue == value
                        ? Colors.white
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
