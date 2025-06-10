import 'package:flutter_test/flutter_test.dart';
import 'package:an_open_soul_app/main.dart'; // ✅ Подключаем main.dart

void main() {
  testWidgets('MyApp renders correctly', (WidgetTester tester) async {
    // ✅ Запускаем приложение в тестовом окружении
    await tester.pumpWidget(const MyApp());





    // ✅ Проверяем, что на экране есть текст "Welcome!"
    expect(find.text("Welcome!"), findsOneWidget);
  });
}
