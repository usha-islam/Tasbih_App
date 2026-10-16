import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';
import 'package:tasbih_app/home_widgets.dart';
import 'package:tasbih_app/counter_widgets.dart';
import 'package:tasbih_app/storage.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
    const Size(320, 433),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('home card and selectors $size scale=$scale', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(() {
          tester.view.reset();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        SharedPreferences.setMockInitialValues({
          'tasbih_count': 32,
          'tasbih_target': 33,
        });
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(HomeWelcomeCard),
            matching: find.text('Keep your heart present'),
          ),
          findsOneWidget,
        );
        expect(find.text('Keep your heart present'), findsOneWidget);
        final card = find.byKey(const ValueKey('home-welcome-card'));
        if (scale == 1 && size.width >= 360 && size.width <= 412) {
          expect(tester.getSize(card).height, inInclusiveRange(110, 145));
        }
        final scroll = find
            .descendant(
              of: find.byKey(const ValueKey('home-scroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        Rect rect(Finder finder) => tester
            .getRect(finder)
            .shift(
              Offset(0, tester.state<ScrollableState>(scroll).position.pixels),
            );
        List<Rect> chipRects() => List.generate(4, (i) {
          final chip = find.byKey(ValueKey('home-target-$i'));
          return rect(
            find.descendant(of: chip, matching: find.byType(Material)).first,
          );
        });
        final initial = chipRects();
        for (final r in initial) {
          expect(r.height, greaterThanOrEqualTo(48));
          expect(r.height, closeTo(initial.first.height, .01));
        }
        for (final pair in [
          [0, 1],
          [2, 3],
        ]) {
          expect(initial[pair[0]].top, initial[pair[1]].top);
          expect(initial[pair[0]].bottom, initial[pair[1]].bottom);
        }
        final circle = find.byKey(const ValueKey('counter-circle'));
        final original = rect(circle);
        expect(original.center.dx, closeTo(size.width / 2, .01));
        await tapText(tester, 'Tap to count');
        expect(
          tester.widget<CounterSurface>(find.byType(CounterSurface)).count,
          33,
        );
        expect(rect(circle), original);
        await tapText(tester, 'Tap to count');
        expect(rect(circle), original);
        await tapText(tester, 'Undo');
        expect(rect(circle), original);
        await tapText(tester, '100');
        for (var i = 0; i < 4; i++) {
          final actual = chipRects()[i];
          expect(actual.left, closeTo(initial[i].left, .01));
          expect(actual.top, closeTo(initial[i].top, .01));
          expect(actual.width, closeTo(initial[i].width, .01));
          expect(actual.height, closeTo(initial[i].height, .01));
        }
        await tapText(tester, 'Custom');
        await tester.enterText(find.byType(TextField), '10000');
        await tapText(tester, 'Set target');
        for (var i = 0; i < 4; i++) {
          final actual = chipRects()[i];
          expect(actual.left, closeTo(initial[i].left, .01));
          expect(actual.top, closeTo(initial[i].top, .01));
          expect(actual.width, closeTo(initial[i].width, .01));
          expect(actual.height, closeTo(initial[i].height, .01));
        }
        expect(
          tester.widget<CounterSurface>(find.byType(CounterSurface)).target,
          10000,
        );
        await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Free count'));
        for (var i = 0; i < 4; i++) {
          final actual = chipRects()[i];
          expect(actual.left, closeTo(initial[i].left, .01));
          expect(actual.top, closeTo(initial[i].top, .01));
          expect(actual.width, closeTo(initial[i].width, .01));
          expect(actual.height, closeTo(initial[i].height, .01));
        }
        expect(rect(circle), original);
        await tapVisible(tester, find.widgetWithText(ChoiceChip, '33'));
        for (var i = 0; i < 4; i++) {
          final actual = chipRects()[i];
          expect(actual.left, closeTo(initial[i].left, .01));
          expect(actual.top, closeTo(initial[i].top, .01));
          expect(actual.width, closeTo(initial[i].width, .01));
          expect(actual.height, closeTo(initial[i].height, .01));
        }
        await tapText(tester, 'Reset count');
        await tapText(tester, 'Cancel');
        expect(
          (await SharedPreferences.getInstance()).getInt('tasbih_count'),
          33,
        );
        await tapText(tester, 'Sound off');
        await tapText(tester, 'Sound on');
        await tapText(tester, 'Vibration off');
        await tapText(tester, 'Vibration on');
        await saves.idle;
        expect(tester.takeException(), isNull);
      });
    }
  }
}
