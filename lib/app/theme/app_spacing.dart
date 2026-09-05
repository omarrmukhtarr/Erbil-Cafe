import 'package:flutter/widgets.dart';

/// Spacing on a 4pt grid.
///
/// v1 sized everything against a fixed 375×812 design and scaled it per device,
/// which stretched type on tablets and squashed it on small phones. Fixed
/// spacing with responsive layout behaves predictably at every size.
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;
  static const jumbo = 56.0;

  /// Horizontal page padding. One value everywhere so every screen's content
  /// shares a single left edge.
  static const page = 20.0;

  /// Vertical rhythm between major sections.
  static const section = 28.0;

  /// Clearance above the tab bar so content never hides behind it.
  static const bottomBarClearance = 96.0;
}

/// Vertical whitespace. Reads better than a bare `SizedBox(height: …)` and
/// keeps the call sites on the scale.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  const Gap.xxs({super.key}) : size = AppSpacing.xxs;
  const Gap.xs({super.key}) : size = AppSpacing.xs;
  const Gap.sm({super.key}) : size = AppSpacing.sm;
  const Gap.md({super.key}) : size = AppSpacing.md;
  const Gap.lg({super.key}) : size = AppSpacing.lg;
  const Gap.xl({super.key}) : size = AppSpacing.xl;
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;
  const Gap.section({super.key}) : size = AppSpacing.section;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Horizontal whitespace.
class HGap extends StatelessWidget {
  const HGap(this.size, {super.key});

  const HGap.xs({super.key}) : size = AppSpacing.xs;
  const HGap.sm({super.key}) : size = AppSpacing.sm;
  const HGap.md({super.key}) : size = AppSpacing.md;
  const HGap.lg({super.key}) : size = AppSpacing.lg;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size);
}
