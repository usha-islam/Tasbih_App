import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadAppFonts() async {
  await (FontLoader('Lato')
        ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Lato-Italic.ttf'))
        ..addFont(rootBundle.load('assets/fonts/Lato-BoldItalic.ttf')))
      .load();
  await (FontLoader(
    'NotoNaskhArabic',
  )..addFont(rootBundle.load('assets/fonts/NotoNaskhArabic.ttf'))).load();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.pumpAndSettle();
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
      maxScrolls: 100,
    );
  }
  await tester.ensureVisible(finder.last);
  await tester.pumpAndSettle();
  await tester.tap(finder.last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> tapText(WidgetTester tester, String text) => tapVisible(
  tester,
  find.byWidgetPredicate((widget) => widget is Text && widget.data == text),
);
Future<void> back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> enterField(WidgetTester tester, String label, String value) async {
  final field = find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
  );
  if (field.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      field,
      150,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
      maxScrolls: 100,
    );
  }
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}
