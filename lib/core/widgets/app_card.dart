import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';

/// A near-black card, as v1 drew its tiles on the cream page.
///
/// Because the card's surface is dark while the page around it is light, any
/// text inside needs the opposite ink. This applies that flip once — via a
/// nested [Theme] and [IconTheme] — so callers can keep using
/// `theme.textTheme.*` without every widget remembering which surface it is on.
///
/// A tappable card also shrinks slightly while it is held. The ink ripple on
/// its own is nearly invisible on `#17191F`, which made large cards feel like
/// they had not registered the touch on a slow connection; the scale reads on
/// any surface and starts on the same frame as the finger.
class AppCard extends StatefulWidget {
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
  State<AppCard> createState() => _AppCardState();

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

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final surface = theme.cardTheme.color ?? AppColors.cardDark;

    Widget content = widget.child;
    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }

    final card = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardR,
        boxShadow: widget.elevated && isLight
            ? [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.18),
                  // The shadow tightens as the card is pressed, which is what
                  // makes it read as moving towards the page rather than just
                  // getting smaller.
                  blurRadius: _pressed ? 10 : 18,
                  offset: Offset(0, _pressed ? 3 : 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: surface,
        borderRadius: AppRadius.cardR,
        clipBehavior: widget.clip ? Clip.antiAlias : Clip.none,
        child: AppCard.cardContent(
          context,
          widget.onTap == null
              ? content
              : InkWell(
                  onTap: widget.onTap,
                  // Fires on the same frame as the touch, and again when it
                  // is released or the gesture is lost to a scroll — so a card
                  // never stays shrunk after a fling.
                  onHighlightChanged: (value) {
                    if (_pressed != value) setState(() => _pressed = value);
                  },
                  child: content,
                ),
        ),
      ),
    );

    if (widget.onTap == null) return card;

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      child: card,
    );
  }
}

/// Muted body text on a dark card.
TextStyle? cardMuted(BuildContext context) => Theme.of(context)
    .textTheme
    .bodySmall
    ?.copyWith(color: AppColors.onCardMuted);
