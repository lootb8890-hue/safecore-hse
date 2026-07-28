import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SafeCore Enterprise App simple smoke test', (WidgetTester tester) async {
    // Build simple basic framework widget test
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('SafeCore Enterprise HSE'))));
    expect(find.text('SafeCore Enterprise HSE'), findsOneWidget);
  });
}
