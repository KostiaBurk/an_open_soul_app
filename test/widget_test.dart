import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:an_open_soul_app/main.dart'; // ✅ Исправлен import

void main() {
  testWidgets('MyApp renders correctly', (WidgetTester tester) async {
    // ✅ Убедились, что нет лишних const
    await tester.pumpWidget(const MaterialApp(
      home: MyApp(), // Убедитесь, что MyApp не требует const
    ));

    // ✅ Проверяем, что на экране есть текст "Welcome!"
    expect(find.text("Welcome!"), findsOneWidget);
  });
}
