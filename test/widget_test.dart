import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tasbih_app/main.dart';

void main() {
  testWidgets('Tasbih increments when tapped', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.text('Tasbih').last);
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Home counter fits a short screen at its increased size', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 433);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final counterSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Tasbih, count 0',
    );
    final counter = find.descendant(
      of: counterSemantics,
      matching: find.byType(Container),
    );
    expect(tester.getSize(counter.first).width, 235);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Custom target accepts and confirms a value through 10000', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final customTargetField = find.byType(TextField);
    expect(
      tester.widget<TextField>(customTargetField).decoration?.hintText,
      '1 - 10000',
    );
    await tester.ensureVisible(customTargetField);
    await tester.enterText(customTargetField, '10000');
    final setTargetButton = find.byTooltip('Set custom target');
    await tester.ensureVisible(setTargetButton);
    await tester.tap(setTargetButton);
    await tester.pumpAndSettle();

    expect(find.text('of 10000'), findsOneWidget);
    expect(find.text('Target set to 10000'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getInt('tasbih_target'),
      10000,
    );
  });

  testWidgets('Dhikr library opens and allows setting a dhikr target', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'zikir_subhanallah_count': 12,
      'zikir_alhamdulillah_count': 7,
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final dhikrButton = find.text('Dhikr list');
    await tester.ensureVisible(dhikrButton);
    await tester.tap(dhikrButton);
    await tester.pumpAndSettle();
    expect(find.text('Your dhikr list'), findsOneWidget);

    final subhanAllah = find.text('SubhanAllah').first;
    await tester.ensureVisible(subhanAllah);
    await tester.tap(subhanAllah);
    await tester.pumpAndSettle();
    final targetPrompt = find.text('Set a target to begin');
    expect(targetPrompt, findsOneWidget);
    final promptWidget = tester.widget<Text>(targetPrompt);
    expect(promptWidget.maxLines, 1);
    expect(promptWidget.style?.fontSize, 15);

    final targetField = find.byType(TextField);
    await tester.ensureVisible(targetField);
    await tester.enterText(targetField, '10000');
    await tester.tap(find.byTooltip('Set target'));
    await tester.pumpAndSettle();

    expect(find.text('12 / 10000'), findsOneWidget);
    expect(find.text('Target set to 10000'), findsOneWidget);
    await tester.tap(find.text('Reset count'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 10000'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('zikir_subhanallah_count'), 0);
    expect(preferences.getInt('zikir_alhamdulillah_count'), 7);
  });

  testWidgets('Prayer dhikr counter resets and clears completion', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'zikir_subhanallah_count': 33,
      'zikir_subhanallah_completed': true,
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final dailyDhikrButton = find.text('Daily Dhikr');
    await tester.ensureVisible(dailyDhikrButton);
    await tester.tap(dailyDhikrButton);
    await tester.pumpAndSettle();

    final fajrTile = find.text('Fajr').first;
    await tester.ensureVisible(fajrTile);
    await tester.tap(fajrTile);
    await tester.pumpAndSettle();

    final subhanAllahTile = find.text('SubhanAllah ×33');
    await tester.ensureVisible(subhanAllahTile);
    await tester.tap(subhanAllahTile);
    await tester.pumpAndSettle();
    expect(find.text('33 / 33'), findsOneWidget);

    await tester.tap(find.text('Reset count'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 33'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getInt('zikir_subhanallah_count'), 0);
    expect(preferences.getBool('zikir_subhanallah_completed'), false);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('Custom daily dhikr accepts a target of 10000', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final dailyDhikrButton = find.text('Daily Dhikr');
    await tester.ensureVisible(dailyDhikrButton);
    await tester.tap(dailyDhikrButton);
    await tester.pumpAndSettle();

    final fajrTile = find.text('Fajr').first;
    await tester.ensureVisible(fajrTile);
    await tester.tap(fajrTile);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    final addCustomButton = find.text('Add custom dhikr or dua');
    await tester.ensureVisible(addCustomButton);
    await tester.tap(addCustomButton);
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Custom remembrance');
    await tester.enterText(fields.at(1), '10000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Custom remembrance ×10000'), findsOneWidget);
  });

  testWidgets('Daily Zikir only completes after reaching target', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final dailyZikirButton = find.text('Daily Dhikr');
    await tester.ensureVisible(dailyZikirButton);
    await tester.tap(dailyZikirButton);
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNothing);

    final fajrTile = find.text('Fajr').first;
    await tester.ensureVisible(fajrTile);
    await tester.tap(fajrTile);
    await tester.pumpAndSettle();

    final allahuAkbarItem = find.text('Allahu Akbar ×34');
    await tester.ensureVisible(allahuAkbarItem);
    await tester.tap(allahuAkbarItem);
    await tester.pumpAndSettle();
    expect(find.text('0 / 34'), findsOneWidget);
    expect(find.text('Done'), findsNothing);

    for (var tap = 0; tap < 34; tap++) {
      await tester.tap(find.text('Tap to count'));
    }
    await tester.pumpAndSettle();
    expect(find.text('34 / 34'), findsOneWidget);
    expect(find.text('Alhamdulillah! Completed.'), findsOneWidget);

    final doneButton = find.text('Done');
    await tester.ensureVisible(doneButton);
    await tester.tap(doneButton);
    await tester.pumpAndSettle();
    final completedItem = find.text('Allahu Akbar ×34');
    await tester.ensureVisible(completedItem);
    expect(completedItem, findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
