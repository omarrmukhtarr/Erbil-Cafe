import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;

          // Guests browse freely, so the profile tab offers a sign-in rather
          // than being unreachable.
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.creamSunken,
                      child: Icon(Icons.person_outline,
                          size: 40, color: AppColors.onCreamMuted),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(l10n.signInRequired,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.signInToFavorite,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: () => context.push(Routes.signIn),
                      child: Text(l10n.signIn),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.lg,
                AppSpacing.page, AppSpacing.bottomBarClearance),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.cream,
                    child: Text(
                      user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: theme.textTheme.titleLarge),
                        if (user.email != null)
                          Text(user.email!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),

              if (user.stats != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    _Stat(
                      value: user.stats!.favorites,
                      label: l10n.favorites,
                    ),
                    _Stat(value: user.stats!.reviews, label: l10n.reviews),
                    _Stat(
                      value: user.stats!.reservations,
                      label: l10n.reservations,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

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
              _Tile(
                icon: Icons.settings_outlined,
                label: l10n.settings,
                onTap: () => context.push(Routes.settings),
              ),

              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton.icon(
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  l10n.signOut,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
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
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.cardR,
        ),
        child: Column(
          children: [
            Text('$value', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
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
