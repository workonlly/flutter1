// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:newfli/main.dart' as app;

void main() {
  testWidgets('Basic UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const app.MyApp());

    // Verify expected UI strings are present.
    expect(find.text('SummariZer'), findsOneWidget);
    expect(find.text('Click Me'), findsOneWidget);
    expect(find.text('Go to Login'), findsOneWidget);
  });
}
