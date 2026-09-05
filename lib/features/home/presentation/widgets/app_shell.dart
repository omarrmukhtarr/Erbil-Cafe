import 'dart:io' show Platform;

import 'package:cupertino_native_better/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The tab shell, with a bar that follows each platform's own convention.
///
/// v1 vendored a copied `CurvedNavigationBar` into `lib/src/Navbar/` — a
/// hand-painted CustomPainter that matched neither platform, ignored the safe
/// area and carried no semantics. This uses each platform's real component:
///
/// * **iOS** — [CNTabBar], a real UIKit tab bar rendered as a platform view by
///   `cupertino_native_better`. Flutter exposes no Liquid Glass API on any
///   channel, so the material has to come from the platform. This replaced a
///   hand-rolled `UIGlassEffect` bridge because a bare platform view bleeds
///   through a modal scrim under iOS hybrid composition — the tab bar stayed
///   bright while the page behind a sheet dimmed. `CNTabBar` tears its view
///   down for the duration of a modal, driven by [CNTabBarRouteObserver].
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
        // SF Symbol names for the native bar; Material icons for Android.
        _Tab(l10n.home, 'cup.and.saucer', 'cup.and.saucer.fill',
            Icons.coffee_outlined, Icons.coffee_rounded),
        _Tab(l10n.explore, 'magnifyingglass', 'magnifyingglass',
            Icons.storefront_outlined, Icons.storefront),
        _Tab(l10n.map, 'map', 'map.fill', Icons.map_outlined, Icons.map),
        _Tab(l10n.favorites, 'heart', 'heart.fill',
            Icons.favorite_border, Icons.favorite),
        _Tab(l10n.profile, 'person', 'person.fill',
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

/// Maps between a tab's position in the list and its position on screen.
///
/// The mapping is its own inverse, so one function serves both directions:
/// reversing twice returns the original index.
@visibleForTesting
int mirrorTabIndex(int index, int count, {required bool isRtl}) {
  if (!isRtl || count == 0) return index;
  return count - 1 - index;
}

class _Tab {
  const _Tab(
    this.label,
    this.symbol,
    this.activeSymbol,
    this.materialIcon,
    this.materialActiveIcon,
  );

  final String label;

  /// SF Symbol name, resolved natively on iOS.
  final String symbol;
  final String activeSymbol;

  final IconData materialIcon;
  final IconData materialActiveIcon;
}

/// iOS: a real UIKit tab bar, so the Liquid Glass material, its selection
/// platter and its spring animations come from the system rather than being
/// approximated in Dart.
class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.tabs,
    required this.index,
    required this.onTap,
  });

  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onTap;

  /// SF Symbols carry more visual weight than Material icons at the same point
  /// size. The plugin's default of 24 crowded the labels and made the bar look
  /// oversized against Apple's own.
  static const _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // UIKit mirrors a tab bar only when the *app* is right-to-left, which it
    // decides from the bundle's localizations — and ours ships only English.
    // The app's own language is chosen in Dart, so a Kurdish or Arabic user on
    // an English phone got a mirrored Flutter UI with an unmirrored native bar.
    //
    // Ordering the items ourselves keeps the two in step whatever the device
    // language is. If CFBundleLocalizations is ever added for ar/ku, UIKit will
    // start mirroring too and this must be removed, or the two cancel out.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final ordered = isRtl ? tabs.reversed.toList() : tabs;

    return CNTabBar(
      currentIndex: mirrorTabIndex(index, tabs.length, isRtl: isRtl),
      onTap: (i) => onTap(mirrorTabIndex(i, tabs.length, isRtl: isRtl)),
      // The accent carries through to the native selection platter.
      tint: AppColors.accent,
      backgroundColor: isLight ? AppColors.cream : AppColors.ink,
      // Montserrat, not the app's RalewaySemi: a semibold display face reads
      // heavy and foreign at tab-bar size next to SF Symbols.
      //
      // The family must be set for the size to apply at all — the plugin's
      // applyLabelFont returns early when it is null, and the label falls back
      // to UIKit's default size.
      labelFontFamily: 'Montserrat',
      labelFontSize: 10,
      // Note: CNTabBar.iconSize is only a fallback for items whose symbol
      // carries no size of its own, and CNSymbol always defaults to 24 — so
      // the size has to be set per symbol below or it has no effect.
      iconSize: _iconSize,
      // Drops the platform view while a sheet is up, so the scrim dims the bar
      // instead of it bleeding through.
      items: [
        for (final tab in ordered)
          CNTabBarItem(
            label: tab.label,
            icon: CNSymbol(tab.symbol, size: _iconSize),
            activeIcon: CNSymbol(tab.activeSymbol, size: _iconSize),
          ),
      ],
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
