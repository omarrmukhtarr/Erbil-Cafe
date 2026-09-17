import 'package:erbilcafe/app/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A state that flips back before its fade-out has finished.
///
/// Tapping the map's location button twice, double-tapping a heart, or a list
/// that reloads and settles inside 280 ms all do this. Each put two children
/// with the same key into the switcher at once, which broke the element tree:
/// the app froze and then showed a red "_dependents.isEmpty" screen.
void main() {
  Widget host(bool on, Widget Function(bool) build) =>
      MaterialApp(home: Scaffold(body: Center(child: build(on))));

  /// Flips the state [times] times, [gap] apart — faster than the animation.
  Future<void> flicker(WidgetTester tester, Widget Function(bool) app, {int times = 5, int gap = 16}) async {
    var on = true;
    await tester.pumpWidget(app(on));
    for (var i = 0; i < times; i++) {
      on = !on;
      await tester.pumpWidget(app(on));
      await tester.pump(Duration(milliseconds: gap));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('FadeSwitcher survives flickering between states', (tester) async {
    await flicker(
      tester,
      (on) => host(
        on,
        (on) => FadeSwitcher(
          child: on
              ? const Text('A', key: ValueKey('a'))
              : const Text('B', key: ValueKey('b')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('PopSwitcher survives tapping a heart several times fast', (tester) async {
    await flicker(
      tester,
      (on) => host(
        on,
        (on) => PopSwitcher(
          child: Icon(on ? Icons.favorite : Icons.favorite_border, key: ValueKey(on)),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('FadeSwitcher survives A → B → A inside one transition', (tester) async {
    Widget child(bool on) => FadeSwitcher(
          child: on
              ? const Text('A', key: ValueKey('a'))
              : const Text('B', key: ValueKey('b')),
        );

    await tester.pumpWidget(host(true, child));
    await tester.pumpWidget(host(false, child));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(host(true, child));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('PopSwitcher survives a double tap', (tester) async {
    Widget child(bool on) => PopSwitcher(
          child: Icon(on ? Icons.favorite : Icons.favorite_border, key: ValueKey(on)),
        );

    await tester.pumpWidget(host(false, child));
    await tester.pumpWidget(host(true, child));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpWidget(host(false, child));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pumpWidget(host(true, child));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('a card fading out does not clash with its replacement over a Hero tag',
      (tester) async {
    Widget child(bool on) => FadeSwitcher(
          child: SizedBox(
            key: ValueKey(on),
            width: 100,
            height: 100,
            child: const Hero(tag: 'cafe-image-1', child: ColoredBox(color: Colors.brown)),
          ),
        );

    final navigator = GlobalKey<NavigatorState>();
    Widget app(bool on) => MaterialApp(
          navigatorKey: navigator,
          home: Scaffold(body: child(on)),
        );

    await tester.pumpWidget(app(true));
    await tester.pumpWidget(app(false));
    await tester.pump(const Duration(milliseconds: 50));
    // Navigating mid-fade is what starts a Hero flight.
    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Hero(tag: 'cafe-image-1', child: SizedBox()))),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
