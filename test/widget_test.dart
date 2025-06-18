import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playmobil_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaymobilApp());
    expect(find.text('¡Bienvenido a Playmobil App!'), findsOneWidget);
  });
}