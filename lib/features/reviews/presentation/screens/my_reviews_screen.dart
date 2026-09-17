import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';

/// Every review the user has written, with a way to change or remove each.
///
/// The API has served this list since reviews existed; nothing in the app
/// showed it, so a review could only be found again by remembering which café
/// it was on.
class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  /// Replaced on every load. An AnimatedList reads its item count only when
  /// it is created, so a list that had folded down to nothing stayed empty
  /// after a reload — which is how a failed delete lost the review from view.
  var _listKey = GlobalKey<AnimatedListState>();
  List<Review>? _reviews;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final page = await sl<ReviewRepository>().mine();
      if (!mounted) return;
      setState(() {
        _listKey = GlobalKey<AnimatedListState>();
        _reviews = [...page.items];
        _failure = null;
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _failure = failure);
    }
  }

  Future<void> _edit(Review review) async {
    final slug = review.cafe?.slug;
    if (slug == null) return;
    final saved = await context.push<bool>(Routes.review(slug));
    if ((saved ?? false) && mounted) await _load();
  }

  Future<void> _delete(Review review) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteReviewConfirm),
        content: Text(l10n.deleteReviewExplain),
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

    final reviews = _reviews;
    final index = reviews?.indexOf(review) ?? -1;
    if (reviews == null || index == -1) return;

    // Folds away at once; put back if the server refuses.
    reviews.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _Removing(
        animation: animation,
        child: _ReviewCard(review: review, onEdit: () {}, onDelete: () {}),
      ),
      duration: AppMotion.medium,
    );
    if (reviews.isEmpty) {
      Future<void>.delayed(AppMotion.medium, () {
        if (mounted) setState(() {});
      });
    }

    try {
      await sl<ReviewRepository>().delete(review.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewDeleted)));
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      if (mounted) await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviews = _reviews;

    final Widget body;
    if (reviews == null && _failure != null) {
      body = ErrorView(
          key: const ValueKey('error'), failure: _failure!, onRetry: _load);
    } else if (reviews == null) {
      body = SkeletonGroup(
        key: const ValueKey('loading'),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.page),
          itemCount: 4,
          separatorBuilder: (_, __) => const Gap.md(),
          itemBuilder: (_, __) =>
              const AppSkeleton(height: 140, radius: AppRadius.card),
        ),
      );
    } else if (reviews.isEmpty) {
      body = EmptyView(
        key: const ValueKey('empty'),
        icon: Icons.rate_review_outlined,
        title: l10n.noMyReviews,
        message: l10n.noMyReviewsBody,
      );
    } else {
      body = RefreshIndicator(
        key: const ValueKey('list'),
        color: AppColors.accent,
        onRefresh: _load,
        child: AnimatedList(
          key: _listKey,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.huge,
          ),
          initialItemCount: reviews.length,
          itemBuilder: (context, index, animation) {
            final review = reviews[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: FadeSlideIn(
                index: index,
                child: _ReviewCard(
                  review: review,
                  onTap: review.cafe == null
                      ? null
                      : () => context.push(Routes.cafe(review.cafe!.slug)),
                  onEdit: () => _edit(review),
                  onDelete: () => _delete(review),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReviews)),
      body: FadeSwitcher(child: body),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  final Review review;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    review.cafe?.name ?? '',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: AppColors.onCard),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const HGap.sm(),
                Text(
                  Formatters.ago(review.createdAt, l10n),
                  style: const TextStyle(
                      color: AppColors.onCardMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Gap.xs(),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: i <= review.rating
                      ? AppColors.accent
                      : AppColors.onCardDisabled,
                ),
            ],
          ),
          if (review.comment?.isNotEmpty ?? false) ...[
            const Gap.sm(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
              child: Text(
                review.comment!,
                style: const TextStyle(
                    color: AppColors.onCard, fontSize: 14, height: 1.5),
              ),
            ),
          ],
          if (review.reply != null) ...[
            const Gap.md(),
            Container(
              margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.cardDarkAlt,
                borderRadius: AppRadius.chipR,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.replyFromCafe,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700),
                  ),
                  const Gap.xs(),
                  Text(
                    review.reply!.body,
                    style: const TextStyle(
                        color: AppColors.onCardMuted,
                        fontSize: 13,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.edit),
              ),
              TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorOnDark),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Removing extends StatelessWidget {
  const _Removing({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved =
        CurvedAnimation(parent: animation, curve: AppMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: SizeTransition(
        sizeFactor: curved,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: IgnorePointer(child: child),
        ),
      ),
    );
  }
}
