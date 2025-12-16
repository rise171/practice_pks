import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_sqlite_app/models/note.dart';

class DBHelper {
  static const _dbName = 'app.db';
  static const _dbVersion = 3; // Увеличиваем версию для миграции
  static Database? _db;

  static const notesTable = 'notes';

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docs.path, _dbName);
    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $notesTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            is_favorite INTEGER NOT NULL DEFAULT 0
          );
        ''');

        // ОПТИМИЗАЦИЯ 1: Добавляем составной индекс для частых запросов
        await db.execute('''
          CREATE INDEX idx_notes_created_favorite 
          ON $notesTable(created_at DESC, is_favorite);
        ''');

        // ОПТИМИЗАЦИЯ 2: Добавляем индекс для поиска
        await db.execute('''
          CREATE INDEX idx_notes_title_search 
          ON $notesTable(title);
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 3) {
          // Удаляем старые индексы и создаем новые
          try {
            await db.execute('DROP INDEX IF EXISTS idx_notes_created_at');
            await db.execute('DROP INDEX IF EXISTS idx_notes_favorite');
          } catch (_) {}

          // Создаем составные индексы
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_notes_created_favorite 
            ON $notesTable(created_at DESC, is_favorite);
          ''');

          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_notes_title_search 
            ON $notesTable(title);
          ''');
        }
      },
    );
    return _db!;
  }

  // ОПТИМИЗАЦИЯ 3: Добавляем пагинацию
  static Future<List<Note>> fetchNotes({int limit = 50, int offset = 0}) async {
    final db = await _open();
    final rows = await db.query(
      notesTable,
      orderBy: 'created_at DESC, is_favorite DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  // Метод для подсчета общего количества заметок
  static Future<int> countNotes() async {
    final db = await _open();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $notesTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Остальные методы остаются без изменений
  static Future<List<Note>> searchNotes(String query) async {
    final db = await _open();
    final rows = await db.query(
      notesTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map((m) => Note.fromMap(m)).toList();
  }

  static Future<int> insertNote(Note note) async {
    final db = await _open();
    return db.insert(notesTable, note.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  static Future<int> updateNote(Note note) async {
    final db = await _open();
    return db.update(
      notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<int> deleteNote(int id) async {
    final db = await _open();
    return db.delete(notesTable, where: 'id = ?', whereArgs: [id]);
  }
}