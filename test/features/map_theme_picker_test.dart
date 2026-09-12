import 'package:erbilcafe/app/theme/app_colors.dart';
import 'package:erbilcafe/features/map/presentation/screens/map_screen.dart';
import 'package:erbilcafe/features/map/presentation/screens/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// The map style sheet.
///
/// The picker is private to `map_screen.dart`, so it is reached the way a user
/// reaches it — by opening the sheet — rather than by constructing the widget.
void main() {
  /// Opens the style sheet and returns the tester, with [current] selected.
  Future<void> openPicker(WidgetTester tester, MapTheme current) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<MapTheme>(
              context: context,
              showDragHandle: true,
              builder: (_) => mapThemePickerForTest(current),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The size of the coloured box behind one theme's label.
  Size swatchSize(WidgetTester tester, String label) {
    final tile = find.ancestor(
      of: find.text(label),
      matching: find.byType(Column),
    );
    final box = find
        .descendant(of: tile.first, matching: find.byType(AnimatedContainer))
        .first;
    return tester.getSize(box);
  }

  testWidgets('every swatch is the same size, selected or not', (tester) async {
    // The bug: a `Container` with no child fills the loose constraints a
    // `Column` gives it, and one with a child shrinks to that child — so the
    // selected swatch, which was the only one holding a tick, collapsed to the
    // width of the tick while its neighbours stayed full width.
    await openPicker(tester, MapTheme.night);

    final selected = swatchSize(tester, 'Night');
    final unselected = swatchSize(tester, 'Erbil');

    expect(selected.width, unselected.width);
    expect(selected.height, unselected.height);
  });

  testWidgets('the chosen style is marked and returned on tap', (tester) async {
    await openPicker(tester, MapTheme.night);

    // Its label takes the accent, which is what tells you which one is on
    // without reading the tick.
    final label = tester.widget<Text>(find.text('Night'));
    expect(label.style?.color, AppColors.accent);

    expect(find.text('Erbil Night'), findsOneWidget);
    expect(find.text('Aubergine'), findsOneWidget);
  });

  testWidgets('all eight styles are offered', (tester) async {
    await openPicker(tester, MapTheme.erbil);

    for (final option in MapTheme.values) {
      expect(find.text(option.label), findsOneWidget,
          reason: '${option.name} is missing from the picker');
    }
  });
}
