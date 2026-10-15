import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasbih_app/main.dart';

void main() {
  for (final size in [const Size(320, 480), const Size(360, 640)]) {
    testWidgets('Screens and existing actions fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      Future<void> tapText(String text) async {
        final control = find.text(text);
        if (control.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            control,
            200,
            scrollable: find.byType(Scrollable).last,
          );
        }
        await tester.ensureVisible(control);
        await tester.tap(control);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tester.enterText(find.byType(TextField), '0');
      await tester.ensureVisible(find.byTooltip('Set custom target'));
      await tester.tap(find.byTooltip('Set custom target'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a whole number from 1 to 10000.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tapText('Daily Dhikr');
      await tapText('Fajr');
      await tapText('Astaghfirullah');
      expect(find.text('0 / 3'), findsOneWidget);
      await tapText('Tap to count');
      expect(find.text('1 / 3'), findsOneWidget);
      await tapText('Reset count');
      expect(find.text('0 / 3'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapText('Reset all dhikr');
      await tapText('Add custom dhikr or dua');
      await tapText('Cancel');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapText('Dhikr list');
      final delete = find.byTooltip('Delete La ilaha illallah');
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Delete La ilaha illallah'), findsNothing);
      expect(tester.takeException(), isNull);
      await tapText('SubhanAllah');
      await tapText('Tap to count');
      expect(find.text('Set a target to begin'), findsOneWidget);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '10');
      await tester.ensureVisible(find.byTooltip('Set target'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Set target'));
      await tester.pumpAndSettle();
      await tapText('Tap to count');
      expect(find.text('1 / 10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
