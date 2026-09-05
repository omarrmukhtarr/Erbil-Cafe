# ErbilCafe

A café discovery app for Erbil, Kurdistan — browse cafés, read menus with real
prices, find them on a map, leave reviews and book a table. Kurdish, Arabic and
English with full right-to-left support.

Part of the [ErbilCafe platform](https://github.com/omarrmukhtarr/erbilcafe-backend):
this app, the API, and an admin dashboard.

## Version 2

v1 (2022) was a UI prototype: every café, menu item and map pin was hardcoded in
Dart, sign-in accepted any input, and the booking screens read *"Sorry, Service
Not Availabe For Now"*. v2 keeps the same look and screen flow but runs on a
real backend.

| | v1 | v2 |
|---|---|---|
| Data | Dart literals, 4 cafés | API, 15 cafés with real coordinates |
| Menus | 3 identical 419-line widget files | one data-driven screen |
| Auth | `signInAnon()` printed to console | JWT with refresh-token rotation |
| Search | decorative | real, across all three languages |
| Ratings | hardcoded 4.4 / 80 reviews | real, recomputed on each approval |
| Booking | "Service Not Available" | live availability and capacity |
| Languages | English only | Kurdish, Arabic, English with RTL |
| Maps key | committed in source | platform config, untracked |

## Running

The [API](https://github.com/omarrmukhtarr/erbilcafe-backend) must be running.

```bash
flutter pub get

# iOS simulator (shares the host's localhost)
flutter run --dart-define=API_URL=http://localhost:3100/api/v1

# Android emulator (the host is 10.0.2.2)
flutter run --dart-define=API_URL=http://10.0.2.2:3100/api/v1
```

Seeded accounts: `user@erbilcafe.app` / `user12345`.

### Maps keys

Never commit them. v1's key leaked into this repository's git history and must
be treated as public.

```bash
cp ios/Flutter/Secrets.example.xcconfig ios/Flutter/Secrets.xcconfig
cp android/local.properties.example android/local.properties   # then merge with your existing file
```

Restrict each key to its bundle id / application id in Google Cloud Console.

## Architecture

```
lib/
├── app/         theme tokens, router (go_router + guards), DI
├── core/        network (Dio + refresh interceptor), storage, errors, shared widgets
├── l10n/        app_ku.arb · app_ar.arb · app_en.arb
└── features/    onboarding auth home cafes menu map reviews favorites
                 reservations profile
                 └── each: data/ (models, repositories) · presentation/ (cubits, screens)
```

State is `flutter_bloc` cubits; dependencies come from `get_it`.

**Session handling.** Access tokens live in the platform keystore, not
SharedPreferences. The API rotates refresh tokens and revokes every session if a
used one is replayed, so `AuthInterceptor` collapses concurrent 401s into a
single refresh — two parallel refreshes would sign the user out.

**Localisation.** The API resolves content for the request language, so the app
receives plain strings rather than doing fallback itself. Flutter's built-in RTL
list covers Arabic but not `ku`, so direction is forced from the resolved locale
in `app.dart`. Café carousels use a compact card whose height is deterministic,
because Kurdish and Arabic wrap taller than English.

**Guests browse freely.** Sign-in is asked for at the point an account is
actually needed — saving, reviewing, booking — not as a wall at launch.

## Design system

The signature look is a **cream page carrying near-black cards** — v1's Home,
Menu, Profile and Booking screens all set `backgroundColor: #E6CCB2` and drew
their tiles in `#17191f` with black section headings. Only the two full-bleed
photo screens were dark.

| Token | | Role |
|---|---|---|
| `cream` | `#E6CCB2` | the page |
| `cardDark` | `#17191F` | cards and tiles on it |
| `accent` | `#D17842` | prices, active states, CTAs |
| `badge` | `#231715` | rating chips |
| `shadow` | `#30221F` | card shadow — warm, not grey |
| `ink` | `#141921` | full-bleed photo screens, and the dark theme's page |

Because the card is dark while the page is light, text ink depends on the
surface. `AppCard` applies that flip once, so widgets inside it can keep using
`theme.textTheme.*`. Radii follow v1's scale — 10 chips, 15 inputs, 20 cards,
25/50 pills, 30 sheets. See `lib/app/theme/`.

*Fixed from v1:* `theme.dart` set `fontFamily: "Muli"`, a font never declared in
`pubspec.yaml`, so every screen silently fell back to the platform default.

## Platform conventions

The tab bar is each platform's own component, not a shared imitation.

**iOS — real Liquid Glass.** Flutter exposes no Liquid Glass API on any channel
(checked against stable, beta and master), so `LiquidGlass`
(`lib/core/widgets/liquid_glass.dart`) bridges to UIKit's own `UIGlassEffect`
through a platform view. That is the same material the system uses for its bars
on iOS 26, refraction included. Below iOS 26 it falls back to
`UIBlurEffect(.systemThinMaterial)`, and off-iOS to a `BackdropFilter`.

**Android** gets the Material 3 `NavigationBar` with its own indicator and
motion. v1 vendored a copied `CurvedNavigationBar` that matched neither platform.

## Maps

The Map tab needs a Google Maps key. Without one the iOS SDK raises an uncaught
native exception on the first map view — uncatchable from Dart — so the app asks
the host over a method channel first and falls back to a café list rather than
crashing.

**Clustering.** Pins are grouped by `CafeClustering`, a grid clusterer working
in Web Mercator space so cafés merge when they would actually overlap on screen,
at any latitude or zoom. Google's own `ClusterManager` does this natively but
exposes no way to style its bubbles — they render in the SDK's default blue.
Clustering here costs one O(n) pass per camera settle and, in exchange, the
bubbles are drawn to the palette: they carry a count, and grow and darken with
density. Tapping one zooms to its members; when they are already at the same
spot a sheet lists them, so no café is ever stuck behind an unopenable pin.

**Themes.** All six of v1's map styles are back behind a picker, plus two tuned
to the app's palette. The choice persists.

## Tests

```bash
flutter analyze   # clean
flutter test
```
