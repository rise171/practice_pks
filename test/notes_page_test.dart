import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app/page/note_page.dart';

void main() {
  testWidgets('Проверка на корректный рендер', (
      WidgetTester tester,
      ) async {
    // Запускаем страницу заметок
    await tester.pumpWidget(
      MaterialApp(
        home: NotesPage(),
      ),
    );

    // Проверяем заголовок
    expect(find.text('Мои заметки'), findsOneWidget);

    // Проверяем поле поиска
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Поиск по заголовку...'), findsOneWidget);

    // Проверяем иконку поиска
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Проверяем кнопку добавления
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Открытие диалогового окна', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotesPage(),
      ),
    );

    // Находим и нажимаем кнопку добавления
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);

    // Используем pump() вместо pumpAndSettle() с таймаутом
    await tester.pump(const Duration(milliseconds: 500));

    // Проверяем, что открылся диалог создания заметки
    expect(find.text('Новая заметка'), findsOneWidget);
    expect(find.text('Заголовок'), findsOneWidget);
    expect(find.text('Текст заметки'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
  });

  testWidgets('Dialog cancel button closes dialog', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotesPage(),
      ),
    );

    // Открываем диалог
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // Проверяем, что диалог открыт
    expect(find.text('Новая заметка'), findsOneWidget);

    // Нажимаем кнопку отмены
    await tester.tap(find.text('Отмена'));
    await tester.pump(const Duration(milliseconds: 500));

    // Проверяем, что диалог закрылся
    expect(find.text('Новая заметка'), findsNothing);
    expect(find.text('Мои заметки'), findsOneWidget);
  });

  // простой тест для проверки поиска
  testWidgets('Search field exists and can be interacted with', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotesPage(),
      ),
    );

    // Проверяем поле поиска
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Вводим текст
    await tester.enterText(searchField, 'тест');
    await tester.pump();

    // Проверяем, что текст введен
    expect(find.text('тест'), findsOneWidget);
  });

  // Тест для проверки кнопки очистки поиска
  testWidgets('Search clear button appears with text', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotesPage(),
      ),
    );

    // Изначально кнопки очистки нет
    expect(find.byIcon(Icons.clear), findsNothing);

    // Вводим текст
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'тест');
    await tester.pump();

    // Теперь должна появиться кнопка очистки
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });
}
