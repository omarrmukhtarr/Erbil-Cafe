import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';

/// The tab shell, with a bar that follows each platform's own convention.
///
/// v1 vendored a copied `CurvedNavigationBar` into `lib/src/Navbar/` — a
/// hand-painted CustomPainter that matched neither platform, ignored the safe
/// area and carried no semantics. This uses each platform's real component:
///
/// * **iOS** — [CupertinoTabBar] over UIKit's own `UIGlassEffect`, bridged in
///   [LiquidGlass]. Flutter exposes no Liquid Glass API on any channel, so the
///   material comes from the platform itself rather than being imitated.
/// * **Android** — Material 3 [NavigationBar], which brings the platform's own
///   pill indicator, ripple and motion.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  static const _tabs = [
    Routes.home,
    Routes.explore,
    Routes.map,
    Routes.favorites,
    Routes.profile,
  ];

  int get _index {
    final exact = _tabs.indexOf(location);
    if (exact >= 0) return exact;

    // Prefix match so a nested route keeps its parent tab selected. Skips
    // index 0, whose path is '/' and would match everything.
    for (var i = _tabs.length - 1; i > 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  static bool get _useCupertino =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  List<_Tab> _tabsFor(AppLocalizations l10n) => [
        _Tab(l10n.home, CupertinoIcons.house, CupertinoIcons.house_fill,
            Icons.coffee_outlined, Icons.coffee_rounded),
        _Tab(l10n.explore, CupertinoIcons.search, CupertinoIcons.search,
            Icons.storefront_outlined, Icons.storefront),
        _Tab(l10n.map, CupertinoIcons.map, CupertinoIcons.map_fill,
            Icons.map_outlined, Icons.map),
        _Tab(l10n.favorites, CupertinoIcons.heart, CupertinoIcons.heart_fill,
            Icons.favorite_border, Icons.favorite),
        _Tab(l10n.profile, CupertinoIcons.person, CupertinoIcons.person_fill,
            Icons.person_outline, Icons.person),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = _tabsFor(l10n);
    void onTap(int index) => context.go(_tabs[index]);

    return Scaffold(
      // The bar is translucent, so content scrolls beneath it instead of being
      // clipped above an opaque strip. Screens add bottom padding themselves.
      extendBody: true,
      body: child,
      bottomNavigationBar: _useCupertino
          ? _GlassTabBar(tabs: tabs, index: _index, onTap: onTap)
          : _MaterialTabBar(tabs: tabs, index: _index, onTap: onTap),
    );
  }
}

class _Tab {
  const _Tab(
    this.label,
    this.cupertinoIcon,
    this.cupertinoActiveIcon,
    this.materialIcon,
    this.materialActiveIcon,
  );

  final String label;
  final IconData cupertinoIcon;
  final IconData cupertinoActiveIcon;
  final IconData materialIcon;
  final IconData materialActiveIcon;
}

/// iOS: UIKit's own Liquid Glass material behind a transparent tab bar.
///
/// The material comes from `UIGlassEffect` through a platform view, so it is
/// the same one the system uses for its bars on iOS 26 — refraction included.
/// `CupertinoTabBar` sits on top with a fully transparent background, which
/// also switches off its own blur so the two do not stack.
class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // A light tint keeps the glass tied to the palette instead of reading as
    // neutral system chrome. Kept low so the material still does the work.
    final tint = (isLight ? AppColors.cream : AppColors.ink)
        .withValues(alpha: isLight ? 0.30 : 0.34);

    final hairline =
        (isLight ? AppColors.onCream : Colors.white).withValues(alpha: 0.10);

    return LiquidGlass(
      tint: tint,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: hairline, width: 0.5)),
        ),
        child: CupertinoTabBar(
          currentIndex: index,
          onTap: onTap,
          // Transparent: the glass behind is the background.
          backgroundColor: Colors.transparent,
          activeColor: AppColors.accent,
          inactiveColor:
              isLight ? AppColors.onCreamMuted : AppColors.onCardMuted,
          iconSize: 26,
          height: 52,
          border: null,
          items: [
            for (final tab in tabs)
              BottomNavigationBarItem(
                icon: Icon(tab.cupertinoIcon),
                activeIcon: Icon(tab.cupertinoActiveIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Android: the platform's Material 3 navigation bar.
class _MaterialTabBar extends StatelessWidget {
  const _MaterialTabBar({
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final surface = isLight ? AppColors.creamRaised : AppColors.cardDarkAlt;
    final inactive = isLight ? AppColors.onCreamMuted : AppColors.onCardMuted;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accent.withValues(alpha: 0.18),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : inactive,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : inactive,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onTap,
        height: 68,
        elevation: 3,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.materialIcon),
              selectedIcon: Icon(tab.materialActiveIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
