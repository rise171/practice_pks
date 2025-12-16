import 'package:flutter_test/flutter_test.dart';
import 'package:notes_sqlite_app/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('Корректность создания объекта Note с обычными значениями', () {
      final now = DateTime.now();
      final note = Note(
        title: 'Test Title',
        body: 'Test Body',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, isNull);
      expect(note.title, 'Test Title');
      expect(note.body, 'Test Body');
      expect(note.createdAt, now);
      expect(note.updatedAt, now);
      expect(note.isFavorite, false);
    });

    test('Обработку очень длинных строк в заголовке и теле', () {
      final now = DateTime.now();
      final longTitle = 'A' * 1000;
      final longBody = 'B' * 10000;

      final note = Note(
        title: longTitle,
        body: longBody,
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, longTitle);
      expect(note.body, longBody);
    });

    test('Устойчивость десериализации при отсутствии некоторых ключей в Map', () {
      final map = {
        'id': 1,
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final note = Note.fromMap(map);

      expect(note.id, 1);
      expect(note.title, '');
      expect(note.body, '');
      expect(note.isFavorite, false);
    });

    test('Обработку специальных символов и escape-последовательностей', () {
      final now = DateTime.now();
      final note = Note(
        title: 'Заголовок с русскими символами',
        body: 'Тело заметки\nС новой строкой\tС табуляцией',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.title, contains('русскими'));
      expect(note.body, contains('\n'));
      expect(note.body, contains('\t'));
    });

    test('Сравнение заметок на основе их идентификатора', () {
      final now = DateTime.now();
      final note1 = Note(
        id: 1,
        title: 'Title',
        body: 'Body',
        createdAt: now,
        updatedAt: now,
      );

      final note2 = Note(
        id: 1,
        title: 'Different Title',
        body: 'Different Body',
        createdAt: now,
        updatedAt: now,
      );

      final note3 = Note(
        id: 2,
        title: 'Title',
        body: 'Body',
        createdAt: now,
        updatedAt: now,
      );
      expect(note1.id == note2.id, true);
      expect(note1.id == note3.id, false);
    });
  });
}