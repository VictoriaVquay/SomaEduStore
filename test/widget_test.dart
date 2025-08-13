// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:somaedustore/main.dart'; // Make sure this matches your app's path

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const SomaEduStoreApp(themeMode: ThemeMode.light),
    ); // 🔁 Use your actual main app widget name here
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
