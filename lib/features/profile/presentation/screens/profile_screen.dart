import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/data/models/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// The Profile tab — the account *and* the settings.
///
/// Settings used to be a second screen reached from here, which meant two taps
/// and a page transition to change the app's language. There was never enough
/// on either page to justify the split: everything now lives on one scroll,
/// with the account at the top and the preferences below it.
///
/// Language and appearance sit outside the signed-in branch on purpose. A guest
/// who cannot read the interface needs the language picker more than anyone,
/// and asking them to make an account first would be absurd.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.bottomBarClearance,
            ),
            children: [
              // Guests browse freely, so the profile tab offers a sign-in
              // rather than being unreachable.
              if (user == null)
                const _GuestCard()
              else
                _Account(user: user),

              const Gap.section(),
              const _Divider(),
              const Gap.xl(),

              _SectionTitle(l10n.preferences),
              const Gap.lg(),
              const _LanguagePicker(),

              const Gap.xxl(),
              const _ThemePicker(),

              const Gap.section(),
              const _Divider(),
              const Gap.xl(),

              _SectionTitle(l10n.aboutApp),
              const Gap.sm(),
              const _About(),

              if (user != null) ...[
                const Gap.section(),
                OutlinedButton.icon(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: Text(
                    l10n.signOut,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),

                // Closing the account has to be reachable from inside the app,
                // not only by writing to support: Apple rejects an app that
                // creates accounts and offers no way out of one, and Google
                // asks for the same. It sits below signing out and reads as
                // the quieter of the two, because it is the rarer one.
                const Gap.lg(),
                const _DeleteAccountButton(),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Avatar, name, activity counts and the two pages that belong to an account.
class _Account extends StatelessWidget {
  const _Account({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.cream,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: const TextStyle(
                  // Cream on cream: the initial was invisible.
                  color: AppColors.onCream,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const HGap.lg(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.email != null)
                    Text(
                      user.email!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),

        if (user.stats != null) ...[
          const Gap.xxl(),
          Row(
            children: [
              _Stat(value: user.stats!.favorites, label: l10n.favorites),
              _Stat(value: user.stats!.reviews, label: l10n.reviews),
              _Stat(value: user.stats!.reservations, label: l10n.reservations),
            ],
          ),
        ],

        const Gap.xl(),
        _Tile(
          icon: Icons.event_seat_outlined,
          label: l10n.myBookings,
          onTap: () => context.push(Routes.bookings),
        ),
        _Tile(
          icon: Icons.favorite_border,
          label: l10n.savedCafes,
          onTap: () => context.go(Routes.favorites),
        ),
      ],
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        // Not `colorScheme.surface`: on the light theme that *is* the page
        // (cream), so the card was invisible. The sunken tone is the one the
        // theme already uses for wells, and it inverts correctly in the dark.
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardR,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.surface,
            child: const Icon(Icons.person_outline,
                size: 32, color: AppColors.onCreamMuted),
          ),
          const Gap.lg(),
          Text(l10n.signInRequired, style: theme.textTheme.titleMedium),
          const Gap.sm(),
          Text(
            l10n.signInToFavorite,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Gap.xl(),
          FilledButton(
            onPressed: () => context.push(Routes.signIn),
            child: Text(l10n.signIn),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettings.of(context);

    return _Field(
      label: l10n.language,
      child: _Options<Locale?>(
        value: settings.locale,
        options: [
          // Null follows the device language.
          (null, l10n.themeSystem),
          (const Locale('ku'), 'کوردی'),
          (const Locale('ar'), 'العربية'),
          (const Locale('en'), 'English'),
        ],
        onChanged: (locale) async {
          await settings.setLocale(locale);
          // Persist the choice on the account too, so notifications arrive in
          // the same language on every device.
          if (locale != null && context.mounted) {
            await context
                .read<AuthCubit>()
                .updateProfile(locale: locale.languageCode);
          }
        },
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppSettings.of(context);

    return _Field(
      label: l10n.theme,
      child: _Options<ThemeMode>(
        value: settings.themeMode,
        options: [
          (ThemeMode.dark, l10n.themeDark),
          (ThemeMode.light, l10n.themeLight),
          (ThemeMode.system, l10n.themeSystem),
        ],
        onChanged: settings.setThemeMode,
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.appName} · v2.0.0\n${l10n.appTagline}',
          style: theme.textTheme.bodySmall,
        ),
        const Gap.md(),
        // Much of the café catalogue is imported from OpenStreetMap, whose
        // ODbL licence requires this credit wherever the data is shown. It is
        // a condition of using the data, not a courtesy.
        Text(l10n.dataAttribution, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

/// A settings row: its name above, its choices below.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const Gap.md(),
        child,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleLarge);
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          // Same reason as the guest card: `surface` is the page on light.
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.cardR,
        ),
        child: Column(
          children: [
            Text('$value', style: theme.textTheme.headlineMedium),
            const Gap(2),
            Text(
              label,
              style: theme.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: AppRadius.chipR,
        ),
        child: Icon(icon, size: 20, color: AppColors.accent),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onCreamMuted),
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
                        : AppColors.onCreamMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Delete my account", and the confirmation that has to precede it.
///
/// The dialog says what actually happens rather than only warning that it
/// cannot be undone — the surprising part is not that it is permanent, it is
/// that reviews stay on the café under "Deleted user" and bookings are
/// cancelled. Someone deleting an account over a booking they want gone
/// deserves to know that before, not after.
class _DeleteAccountButton extends StatefulWidget {
  const _DeleteAccountButton();

  @override
  State<_DeleteAccountButton> createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends State<_DeleteAccountButton> {
  bool _busy = false;

  Future<void> _confirmAndDelete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final cubit = context.read<AuthCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountConfirm),
        content: Text(l10n.deleteAccountExplain),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await cubit.deleteAccount();
      if (!mounted) return;

      // Back to the home tab: every screen behind this one belonged to an
      // account that no longer exists.
      router.go(Routes.home);
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextButton.icon(
      onPressed: _busy ? null : _confirmAndDelete,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.error),
            )
          : const Icon(Icons.person_remove_outlined,
              size: 18, color: AppColors.error),
      label: Text(
        l10n.deleteAccountAction,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}
