import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../app/di/injector.dart';
import '../../../app/router/app_router.dart';
import 'dart:math' as math;

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../l10n/app_localizations.dart';

/// Three-page intro, keeping v1's flow but with real copy in all three
/// languages and a skip that is reachable from the first page.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await sl<AppPreferences>().setOnboarded();
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pages = [
      (
        icon: Icons.local_cafe_rounded,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      (
        icon: Icons.menu_book_rounded,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      (
        icon: Icons.event_seat_rounded,
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
    ];

    final isLast = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.skip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return _OnboardingPage(
                    controller: _controller,
                    index: index,
                    icon: page.icon,
                    title: page.title,
                    body: page.body,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: pages.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      activeDotColor: AppColors.accent,
                      dotColor: AppColors.onCreamMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                                duration: AppMotion.slow,
                                curve: AppMotion.standard,
                              ),
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.pillR,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: AppMotion.fast,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        ),
                        child: Text(
                          isLast ? l10n.getStarted : l10n.next,
                          key: ValueKey(isLast),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One onboarding page, moving with the swipe.
///
/// Everything used to slide across as a single flat card. Here the icon, the
/// title and the body travel at different speeds and the icon grows as its
/// page settles, so the swipe has depth — and because it is driven by the
/// page position, not a timer, it follows the finger exactly and reverses if
/// the swipe does.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
  });

  final PageController controller;
  final int index;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final iconCircle = Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(icon, size: 56, color: Colors.white),
    );

    final titleText = Text(
      title,
      style: theme.textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );

    final bodyText = Text(
      body,
      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.onCreamMuted),
      textAlign: TextAlign.center,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // -1 … 0 … 1: how far this page is from the centre of the screen.
        final page = controller.hasClients &&
                controller.position.haveDimensions
            ? controller.page ?? controller.initialPage.toDouble()
            : controller.initialPage.toDouble();
        final delta = (index - page).clamp(-1.0, 1.0);
        final distance = delta.abs();
        final direction = rtl ? -1.0 : 1.0;

        // The page itself moves at full speed; these add to it.
        Widget layer(Widget child, double parallax, {double scale = 1}) {
          return Transform.translate(
            offset: Offset(delta * width * parallax * direction, 0),
            child: Transform.scale(scale: scale, child: child),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: AlwaysStoppedAnimation(1 - distance * 0.6),
                child: layer(
                  Transform.rotate(
                    angle: delta * math.pi / 14,
                    child: iconCircle,
                  ),
                  -0.25,
                  scale: 1 - distance * 0.35,
                ),
              ),
              const SizedBox(height: AppSpacing.huge),
              layer(titleText, 0.15),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: AlwaysStoppedAnimation(1 - distance),
                child: layer(bodyText, 0.3),
              ),
            ],
          ),
        );
      },
    );
  }
}
