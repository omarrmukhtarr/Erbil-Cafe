import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/support.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';

/// Answers to the questions people actually have about the app, and a person
/// to write to when those are not enough.
///
/// Every answer describes what the app does today — "a café with no hours
/// cannot be shown as open" included. A help page that promises more than the
/// app delivers is how a small gap becomes a one-star review.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final questions = [
      (Icons.search_rounded, l10n.faqFindQ, l10n.faqFindA),
      (Icons.schedule_rounded, l10n.faqOpenNowQ, l10n.faqOpenNowA),
      (Icons.favorite_border_rounded, l10n.faqSaveQ, l10n.faqSaveA),
      (Icons.event_seat_outlined, l10n.faqBookQ, l10n.faqBookA),
      (Icons.event_busy_outlined, l10n.faqCancelQ, l10n.faqCancelA),
      (Icons.star_border_rounded, l10n.faqRateQ, l10n.faqRateA),
      (
        Icons.edit_location_alt_outlined,
        l10n.faqWrongInfoQ,
        l10n.faqWrongInfoA
      ),
      (Icons.translate_rounded, l10n.faqLanguageQ, l10n.faqLanguageA),
      (Icons.person_remove_outlined, l10n.faqDeleteQ, l10n.faqDeleteA),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpCenter)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.huge,
        ),
        children: [
          Text(l10n.faqTitle, style: theme.textTheme.titleLarge),
          const Gap.md(),
          for (final (index, (icon, question, answer)) in questions.indexed)
            FadeSlideIn(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child:
                    _Question(icon: icon, question: question, answer: answer),
              ),
            ),
          const Gap.xl(),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.stillNeedHelp,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.onCard),
                ),
                const Gap.xs(),
                Text(
                  l10n.stillNeedHelpBody,
                  style: const TextStyle(
                      color: AppColors.onCardMuted, fontSize: 13, height: 1.5),
                ),
                const Gap.lg(),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Support.contactSupport(context),
                        icon: const Icon(Icons.mail_outline, size: 18),
                        label: Text(l10n.contactSupport,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                const Gap.sm(),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => Support.reportProblem(context),
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        label: Text(l10n.reportProblem,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One question that opens to its answer.
///
/// Hand-built rather than an `ExpansionTile`, whose divider lines and default
/// ink do not belong on the cream page, and whose height change is a snap on
/// some platforms. Here the answer grows open and the chevron turns with it.
class _Question extends StatefulWidget {
  const _Question({
    required this.icon,
    required this.question,
    required this.answer,
  });

  final IconData icon;
  final String question;
  final String answer;

  @override
  State<_Question> createState() => _QuestionState();
}

class _QuestionState extends State<_Question> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.cardR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _open = !_open);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: true,
                expanded: _open,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon, size: 20, color: AppColors.accent),
                    const HGap.md(),
                    Expanded(
                      child: Text(widget.question,
                          style: theme.textTheme.labelLarge),
                    ),
                    const HGap.sm(),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: AppMotion.medium,
                      curve: AppMotion.standard,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: AppMotion.standard,
                alignment: AlignmentDirectional.topStart,
                child: _open
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 20 + AppSpacing.md,
                          top: AppSpacing.sm,
                        ),
                        child: Text(widget.answer,
                            style: theme.textTheme.bodyMedium),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
