import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// A near-black card, as v1 drew its tiles on the cream page.
///
/// Because the card's surface is dark while the page around it is light, any
/// text inside needs the opposite ink. This applies that flip once — via a
/// nested [Theme] and [IconTheme] — so callers can keep using
/// `theme.textTheme.*` without every widget remembering which surface it is on.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.clip = true,
    this.elevated = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool clip;

  /// Cards only cast a shadow on the cream page; on the dark theme a shadow is
  /// invisible and only muddies the surface.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final surface = theme.cardTheme.color ?? AppColors.cardDark;

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardR,
        boxShadow: elevated && isLight
            ? [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: surface,
        borderRadius: AppRadius.cardR,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: cardContent(
          context,
          onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }

  /// Re-inks text and icons for a dark surface.
  static Widget cardContent(BuildContext context, Widget child) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          bodyColor: AppColors.onCard,
          displayColor: AppColors.onCard,
        ),
        iconTheme: const IconThemeData(color: AppColors.onCardMuted),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.onCard),
        child: IconTheme.merge(
          data: const IconThemeData(color: AppColors.onCardMuted),
          child: child,
        ),
      ),
    );
  }
}

/// Muted body text on a dark card.
TextStyle? cardMuted(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onCardMuted);
