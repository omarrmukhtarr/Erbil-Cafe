import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../error/failure.dart';

/// Skeleton placeholder. v1 showed a bare spinner; a skeleton in the shape of
/// the content it replaces reads as faster and avoids a layout jump.
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
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Card-shaped skeleton used while a café list loads.
class CafeCardSkeleton extends StatelessWidget {
  const CafeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(
          aspectRatio: 16 / 10,
          child: AppSkeleton(radius: AppRadius.card),
        ),
        const SizedBox(height: AppSpacing.md),
        const AppSkeleton(height: 18, width: 160),
        const SizedBox(height: AppSpacing.sm),
        const AppSkeleton(height: 12, width: 110),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title,
                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!,
                  style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
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
      UnauthorizedFailure() => (
          Icons.lock_outline,
          l10n.errorUnauthorized,
          null,
        ),
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
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
    );
  }
}
