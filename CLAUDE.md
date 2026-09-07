# ErbilCafe — Flutter app

Read `README.md` first for setup and architecture. This file records only the
conventions that are easy to violate by accident.

## Design

- **The page is cream, the cards are near-black.** This is the app's identity,
  carried over from v1. Never invert it.
- All colours, radii and text styles come from `lib/app/theme/` (`AppColors`,
  `AppRadius`, `AppTypography`). No colour literals in feature code.
- Anything sitting on a dark card goes inside `core/widgets/app_card.dart`, which
  flips the text/icon ink once via a nested `Theme` — so children keep using
  `theme.textTheme.*` normally.

## Things that will bite you

- **The tabs are a `StatefulShellRoute.indexedStack`, one navigator each.** Not
  a plain `ShellRoute` — that put all five tabs in one navigator, so switching
  tabs was a route replacement: iOS animated it like a push and disposed the
  outgoing screen, which made Home refetch five endpoints on every return and
  Explore forget its search. Anything that must survive a tab switch belongs in
  the screen's own `State`; it is kept for the life of the app.
  `test/features/tab_shell_test.dart` pins that.
- **The bottom tab bar is a native view on iOS** (`CNTabBar` from
  `cupertino_native_better`; Material 3 `NavigationBar` on Android). It contains
  no Flutter widgets, so *integration* tests on a simulator must navigate with
  `sl<GoRouter>().go(...)` rather than tapping it. Widget tests report
  `defaultTargetPlatform` as Android and so get the Material bar, which is
  tappable — which is why `AppShell` branches on `defaultTargetPlatform` and
  not on `dart:io`'s `Platform` (`Platform.isMacOS` is true in a widget test,
  and building a UIKit platform view there hangs).
  - UIKit only mirrors it in RTL when the *bundle* is RTL, which ours is not, so
    RTL order is handled in Dart by `mirrorTabIndex` in `app_shell.dart`.
  - `CNTabBar.iconSize` is only a fallback for symbols with no size of their own —
    set the size on each `CNSymbol`. `labelFontSize` is ignored unless
    `labelFontFamily` is also set.
- **Kurdish needs `lib/l10n/kurdish_material_localizations.dart`.** Flutter ships no
  `ku` locale, and `MaterialApp` drops a locale unless *every* delegate supports
  it — that is why `ku` was previously unselectable. Those delegates serve
  Flutter's own strings from Arabic.
- **The map must not be entered without an API key.** A missing key makes
  `GMSServices.provideAPIKey` never run and the crash is native and uncatchable.
  `core/platform/platform_config.dart` checks over a MethodChannel and the screen
  falls back to a café list.
- **Map clustering is our own Dart code** (`features/map/presentation/screens/cafe_clustering.dart`),
  a Web Mercator grid, not the `ClusterManager` from the plugin — we need custom
  bubble styling. Markers are canvas-drawn in `map_markers.dart`.
- `google_maps_flutter` is pinned at/above 2.18.0: older platform-interface
  versions sent `newLatLngZoom` on the wire for a bounds update and crashed iOS.
  `test/features/camera_update_test.dart` pins that format — don't delete it.

## Commands

```
flutter analyze && flutter test
flutter test integration_test/            # real flows, needs a booted simulator
flutter run --dart-define=START_ROUTE=/map # debug-only jump straight to a screen
```

Widget tests render in `ku`, `ar` and `en`; keep it that way — three overflow bugs
were only visible in one locale.

Work happens on the **`v2-rebuild`** branch. `master` is still the 2022 prototype.
