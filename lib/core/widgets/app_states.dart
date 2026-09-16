import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../error/failure.dart';
import 'cafe_card.dart';

/// Skeleton placeholder.
///
/// v1 showed a bare spinner; a skeleton shaped like the content it stands in
/// for reads as faster and avoids the layout jump when data lands.
///
/// On its own a skeleton carries its own shimmer. Inside a [SkeletonGroup] it
/// is a plain box, and the group shimmers once across all of them — which is
/// both cheaper and what the eye expects: one sweep of light across a loading
/// section, not a dozen out of step with each other.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    this.height = 16,
    this.width,
    this.radius = AppRadius.chip,
    super.key,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = _SkeletonColors.of(context);

    final box = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colors.base,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (SkeletonGroup._inside(context)) return box;

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: box,
    );
  }
}

/// One shimmer for every [AppSkeleton] beneath it.
///
/// Each `Shimmer` is its own looping animation and its own shader mask
/// repainting its subtree sixty times a second; a loading Explore list had
/// twelve of them running at once.
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({required this.child, super.key});

  final Widget child;

  static bool _inside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_SkeletonScope>() != null;

  @override
  Widget build(BuildContext context) {
    // Nested groups share the outer shimmer.
    if (_inside(context)) return child;

    final colors = _SkeletonColors.of(context);

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: _SkeletonScope(child: child),
    );
  }
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required super.child});

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) => false;
}

class _SkeletonColors {
  const _SkeletonColors(this.base, this.highlight);

  /// On cream the skeleton must be darker than the page; on ink, lighter.
  static _SkeletonColors of(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return isLight
        ? const _SkeletonColors(AppColors.creamSunken, AppColors.creamRaised)
        : const _SkeletonColors(AppColors.cardDarkAlt, Color(0xFF2A2E37));
  }

  final Color base;
  final Color highlight;
}

/// Card-shaped skeleton used while a café list loads.
class CafeCardSkeleton extends StatelessWidget {
  const CafeCardSkeleton({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSkeleton(
            height: compact ? CafeCard.imageHeightCompact : 190,
            radius: AppRadius.card,
          ),
          const Gap.md(),
          const AppSkeleton(height: 18, width: 170),
          const Gap.sm(),
          const AppSkeleton(height: 13, width: 120),
        ],
      ),
    );
  }
}

/// Shown when a list is genuinely empty — distinct from still loading.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.huge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
            ),
            const Gap.xl(),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const Gap.sm(),
              Text(
                message!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const Gap.xl(),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry, so a transient network blip is recoverable in
/// place instead of forcing the user to back out of the screen.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final (icon, title, message) = switch (failure) {
      NetworkFailure() => (
          Icons.wifi_off_rounded,
          l10n.errorNetwork,
          l10n.errorNetworkBody,
        ),
      TimeoutFailure() => (Icons.timer_off_outlined, l10n.errorTimeout, null),
      UnauthorizedFailure() => (Icons.lock_outline, l10n.errorUnauthorized, null),
      NotFoundFailure() => (Icons.search_off, failure.message, null),
      _ => (Icons.error_outline, l10n.errorGeneric, failure.message),
    };

    return EmptyView(
      icon: icon,
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.retry),
            ),
    );
  }
}

/// Section heading with an optional trailing action, used across the tabs.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
    super.key,
  });

  final String title;

  /// One muted line under the heading, saying what the section is for. A
  /// carousel of cafés reads very differently depending on *why* those cafés
  /// are in it, and the title alone rarely carries that.
  final String? subtitle;

  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.section,
            AppSpacing.sm,
            AppSpacing.md,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const Gap(3),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const HGap.sm(),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
