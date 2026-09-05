import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../error/failure.dart';

/// Skeleton placeholder.
///
/// v1 showed a bare spinner; a skeleton shaped like the content it stands in
/// for reads as faster and avoids the layout jump when data lands.
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    // On cream the skeleton must be darker than the page; on ink, lighter.
    final base = isLight ? AppColors.creamSunken : AppColors.cardDarkAlt;
    final highlight = isLight ? AppColors.creamRaised : const Color(0xFF2A2E37);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Card-shaped skeleton used while a café list loads.
class CafeCardSkeleton extends StatelessWidget {
  const CafeCardSkeleton({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSkeleton(height: compact ? 148 : 190, radius: AppRadius.card),
        const Gap.md(),
        const AppSkeleton(height: 18, width: 170),
        const Gap.sm(),
        const AppSkeleton(height: 13, width: 120),
      ],
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
    this.actionLabel,
    this.onAction,
    this.padding,
    super.key,
  });

  final String title;
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
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
