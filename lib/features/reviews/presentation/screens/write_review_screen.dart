import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../data/repositories/review_repository.dart';

/// Write a review.
///
/// Pops `true` when a review was submitted, so the café page knows to reload
/// its list and rating breakdown.
class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({required this.slug, super.key});

  final String slug;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _comment = TextEditingController();
  double _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    try {
      // The route carries a slug, but creating a review needs the café's id.
      final cafe = await sl<CafeRepository>().detail(widget.slug);

      await sl<ReviewRepository>().create(
        cafe.cafe.id,
        rating: _rating.round(),
        comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
      );

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reviewPending)));
      context.pop(true);
    } on Failure catch (f) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.writeReview)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.yourRating,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                itemCount: 5,
                itemSize: 40,
                glow: false,
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: AppColors.accent,
                ),
                onRatingUpdate: (value) => setState(() => _rating = value),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            TextField(
              controller: _comment,
              maxLines: 6,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.reviewHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: AppRadius.chipR,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.reviewPending,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.submitReview),
            ),
          ],
        ),
      ),
    );
  }
}
