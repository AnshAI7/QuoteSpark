// QuoteSpark - Widget Tests
// Developer: Ansh Mishra | CodeAlpha Internship Project
//
// NOTE: If your pubspec.yaml has a different "name:" field than
// "codealpha_quote_generator", update the import below to match it.
// (Open pubspec.yaml and check the first line, e.g. `name: my_app_name`)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codealpha_quote_generator/main.dart';

// ─────────────────────────────────────────────────────────────
// IMPORTANT: QuoteSpark has a floating-particle background
// animation that repeats forever (AnimationController..repeat()).
// Because it never settles, `pumpAndSettle()` would time out on
// every single test. So instead we use `pumpFrames()` below,
// which pumps a fixed number of frames — enough for fade/scale
// transitions and bottom sheets to finish, without waiting
// forever for the particles to stop (they never will).
// ─────────────────────────────────────────────────────────────

/// Pumps a bounded number of frames instead of pumpAndSettle,
/// since this app has a perpetual particle animation.
Future<void> pumpFrames(
  WidgetTester tester, {
  Duration step = const Duration(milliseconds: 100),
  int times = 10,
}) async {
  for (int i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// Pumps the app with a larger virtual screen so the quote card
/// has enough room and doesn't trigger overflow warnings that
/// happen with the tiny default 800x600 test surface.
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const QuoteApp());
  await pumpFrames(tester);
}

void main() {
  group('QuoteSpark App - Smoke & Widget Tests', () {
    testWidgets('App launches and shows title + a quote card', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // App title should be visible on the home screen.
      expect(find.text('QuoteSpark ✨'), findsOneWidget);

      // A quote card should render some quote text (starts with a quote mark).
      expect(find.textContaining('"'), findsWidgets);

      // "New Quote" button should be present.
      expect(find.text('New Quote'), findsOneWidget);
    });

    testWidgets('Tapping search icon reveals the search bar', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Search bar should not be visible initially.
      expect(
        find.text('Search or describe your mood...'),
        findsNothing,
      );

      // Tap the search icon in the top bar.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await pumpFrames(tester);

      // Search bar should now be visible.
      expect(
        find.text('Search or describe your mood...'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Tapping "New Quote" button does not crash and keeps a quote visible',
      (WidgetTester tester) async {
        await pumpApp(tester);

        await tester.tap(find.text('New Quote'));
        await pumpFrames(tester);

        // A quote should still be visible after tapping New Quote.
        expect(find.textContaining('"'), findsWidgets);
      },
    );

    testWidgets('Tapping the Save button adds current quote to favorites', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Initially "Save" label should be shown (not yet favorited).
      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await pumpFrames(tester);

      // A confirmation snackbar should appear.
      expect(find.text('Added to favorites!'), findsOneWidget);

      // Button label should change to "Saved".
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('Favorites screen opens and shows the saved quote', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Save the current quote first.
      await tester.tap(find.text('Save'));
      await pumpFrames(tester);

      // Open favorites via the heart icon in the top bar.
      await tester.tap(find.byIcon(Icons.favorite_rounded).first);
      await pumpFrames(tester);

      // Favorites screen header should be visible.
      expect(find.text('My Favorites'), findsOneWidget);
      expect(find.text('1 saved'), findsOneWidget);

      // Go back to home screen.
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await pumpFrames(tester);

      expect(find.text('QuoteSpark ✨'), findsOneWidget);
    });

    testWidgets('Copy button shows a confirmation snackbar', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Copy'));
      await pumpFrames(tester);

      expect(find.text('Quote copied!'), findsOneWidget);
    });

    testWidgets('Category chip filters quotes without crashing', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Tap the "Love" category chip.
      await tester.tap(find.text('Love').first);
      await pumpFrames(tester);

      // A quote card should still be displayed after filtering.
      expect(find.textContaining('"'), findsWidgets);
    });

    testWidgets('Mood picker opens and a mood can be selected', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Tap the mood dropdown button.
      await tester.tap(find.text('Mood'));
      await pumpFrames(tester);

      // Bottom sheet title should appear.
      expect(find.text('Choose Your Mood'), findsOneWidget);

      // Select the "Happy" mood.
      await tester.tap(find.text('Happy'));
      await pumpFrames(tester);

      // A quote should still render after mood filter applied.
      expect(find.textContaining('"'), findsWidgets);
    });

    testWidgets('Theme picker opens and a theme can be selected', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      // Tap the palette icon to open theme picker.
      await tester.tap(find.byIcon(Icons.palette_rounded));
      await pumpFrames(tester);

      expect(find.text('Card Theme'), findsOneWidget);

      // Select the "Ocean" theme.
      await tester.tap(find.text('Ocean'));
      await pumpFrames(tester);

      // Quote card should still be rendered.
      expect(find.textContaining('"'), findsWidgets);
    });

    testWidgets('Shuffle button changes/refreshes the quote without crashing', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.text('Shuffle'));
      await pumpFrames(tester);

      expect(find.textContaining('"'), findsWidgets);
    });
  });
}