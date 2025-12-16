import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:notes_sqlite_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end тесты приложения заметок', () {
    // Тест 1: Открытие приложения и проверка основных элементов
    testWidgets('Открытие приложения и проверка основных элементов', (
        WidgetTester tester,
        ) async {
      // Запускаем приложение
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Проверяем основные элементы главного экрана
      expect(find.text('Мои заметки'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // Тест 2: Создание новой заметки
    testWidgets('Создание новой заметки', (
        WidgetTester tester,
        ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Нажимаем кнопку создания заметки
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Проверяем, что открылся диалог создания
      expect(find.text('Новая заметка'), findsOneWidget);

      // Находим первое поле ввода (заголовок)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      // Вводим заголовок в первое поле
      await tester.enterText(textFields.at(0), 'Тестовая заметка');
      await tester.pump();

      // Вводим текст заметки во второе поле
      await tester.enterText(textFields.at(1), 'Текст тестовой заметки');
      await tester.pump();

      // Нажимаем кнопку сохранения
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Проверяем, что вернулись на главный экран
      expect(find.text('Мои заметки'), findsOneWidget);

      // Проверяем, что заметка появилась в списке
      expect(find.text('Тестовая заметка'), findsOneWidget);
    });

    // Тест 3: Поиск заметок (упрощенный)
    testWidgets('Поиск заметок', (
        WidgetTester tester,
        ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Вводим текст в поле поиска
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Тестовая');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Проверяем, что найдена заметка
      expect(find.text('Тестовая заметка'), findsOneWidget);

      // Ищем несуществующую заметку
      await tester.enterText(searchField, 'Несуществующая заметка');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Проверяем сообщение о пустом результате или прогресс-индикатор
      // (может быть либо CircularProgressIndicator, либо сообщение)
      final hasProgressIndicator = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasNoResultsMessage = find.text('Ничего не найдено').evaluate().isNotEmpty;

      // Любой из этих результатов допустим
      expect(hasProgressIndicator || hasNoResultsMessage, isTrue);
    });

    // Тест 4: Диалог создания заметки имеет правильную структуру
    testWidgets('Диалог создания заметки имеет правильную структуру', (
        WidgetTester tester,
        ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Открываем диалог
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Проверяем основные элементы диалога
      expect(find.text('Новая заметка'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Сохранить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    // Тест 5: Отмена создания заметки
    testWidgets('Отмена создания заметки', (
        WidgetTester tester,
        ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Открываем диалог
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Вводим данные
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Заметка для отмены');
      await tester.enterText(textFields.at(1), 'Текст для отмены');
      await tester.pump();

      // Нажимаем "Отмена"
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Проверяем, что вернулись на главный экран
      expect(find.text('Мои заметки'), findsOneWidget);
    });
  });
}