import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notes_sqlite_app/models/note.dart';

class DBHelper {
  static const _dbName = 'app.db';
  static const _dbVersion = 2;
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
        await db.execute('CREATE INDEX idx_notes_created_at ON $notesTable(created_at DESC);');
        await db.execute('CREATE INDEX idx_notes_favorite ON $notesTable(is_favorite);');
      },
      onUpgrade: (db, oldV, newV) async {
        //Миграция
        if (oldV < 2) {
          await db.execute('ALTER TABLE $notesTable ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0;');
          await db.execute('CREATE INDEX idx_notes_favorite ON $notesTable(is_favorite);');
        }
      },
    );
    return _db!;
  }

  static Future<int> insertNote(Note note) async {
    final db = await _open();
    return db.insert(notesTable, note.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  static Future<List<Note>> fetchNotes() async {
    final db = await _open();
    final rows = await db.query(notesTable, orderBy: 'created_at DESC');
    return rows.map((m) => Note.fromMap(m)).toList();
  }

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