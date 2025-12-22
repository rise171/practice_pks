import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/note.dart';

// Виджет для отображения ошибок загрузки данных
class DataErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String contextMessage;

  const DataErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.contextMessage = 'Произошла ошибка при загрузке данных',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_outlined,
                size: 48,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              contextMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    // Дополнительные действия
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Детали ошибки'),
                        content: SingleChildScrollView(
                          child: Text(
                            error.toString(),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Подробнее'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Виджет карточки заметки
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return 'Сегодня в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'Вчера в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: note.key,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 76),
              Theme.of(context).colorScheme.surface.withValues(alpha: 178),
            ],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color.fromARGB(25, 103, 80, 164),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.note_outlined,
              color: Color(0xFF6750A4),
              size: 20,
            ),
          ),
          title: Text(
            note.title.isEmpty ? '(без названия)' : note.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.body,
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 12,
                    color: Color(0xFF79747E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(note.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF79747E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color.fromARGB(25, 179, 38, 30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFB3261E),
                size: 18,
              ),
            ),
            onPressed: onDelete,
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _futureNotes;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Note> _allNotes = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _notesPerPage = 20;

  // Для отображения ошибок
  Object? _lastError;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadInitialNotes();
  }

  void _loadInitialNotes() {
    setState(() {
      _allNotes.clear();
      _currentPage = 0;
      _hasMore = true;
      _hasError = false;
      _lastError = null;
      _futureNotes = _fetchNotesPaginated();
    });
  }

  Future<List<Note>> _fetchNotesPaginated() async {
    if (!_hasMore) return _allNotes;

    setState(() {
      _isLoadingMore = true;
      _hasError = false;
    });

    try {
      final newNotes = await DBHelper.fetchNotes(
        limit: _notesPerPage,
        offset: _currentPage * _notesPerPage,
      );

      setState(() {
        _isLoadingMore = false;

        if (newNotes.isNotEmpty) {
          _allNotes.addAll(newNotes);
          _currentPage++;
        }

        _hasMore = newNotes.length == _notesPerPage;
        _hasError = false;
      });

      return _allNotes;
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingMore = false;
        _hasError = true;
        _lastError = e;
      });

      // Логируем ошибку
      if (kDebugMode) {
        print('Error loading notes: $e');
        print('Stack trace: $stackTrace');
      }

      // Пробрасываем ошибку дальше для обработки в FutureBuilder
      rethrow;
    }
  }

  void _reloadNotes() {
    setState(() {
      _hasError = false;
      _lastError = null;
      if (_searchQuery.isEmpty) {
        _futureNotes = _fetchNotesPaginated();
      } else {
        _futureNotes = _safeSearchNotes(_searchQuery);
      }
    });
  }

  Future<List<Note>> _safeSearchNotes(String query) async {
    try {
      return await DBHelper.searchNotes(query);
    } catch (e, stackTrace) {
      setState(() {
        _hasError = true;
        _lastError = e;
      });

      if (kDebugMode) {
        print('Error searching notes: $e');
        print('Stack trace: $stackTrace');
      }

      // Возвращаем пустой список вместо выброса ошибки
      return [];
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _reloadNotes();
  }

  Future<void> _safeDBAction(
      Future<void> Function() action,
      String successMessage,
      String errorMessage,
      ) async {
    try {
      await action();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Database action failed: $e');
        print('Stack trace: $stackTrace');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Перезагружаем данные в случае ошибки
      _reloadNotes();
    }
  }

  Future<void> _createNote() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _NoteEditDialog(
        titleController: titleController,
        bodyController: bodyController,
        dialogTitle: 'Новая заметка',
      ),
    );

    if (result == true && mounted) {
      await _safeDBAction(() async {
        final now = DateTime.now();
        final newNote = Note(
          title: titleController.text.trim(),
          body: bodyController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        await DBHelper.insertNote(newNote);
        _loadInitialNotes();
      }, 'Заметка создана', 'Ошибка при создании заметки');
    }
  }

  Future<void> _editNote(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.body);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _NoteEditDialog(
        titleController: titleController,
        bodyController: bodyController,
        dialogTitle: 'Редактировать заметку',
      ),
    );

    if (result == true && mounted) {
      await _safeDBAction(() async {
        final updatedNote = note.copyWith(
          title: titleController.text.trim(),
          body: bodyController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await DBHelper.updateNote(updatedNote);
        _reloadNotes();
      }, 'Заметка обновлена', 'Ошибка при обновлении заметки');
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text('Заметка "${note.title.isNotEmpty ? note.title : 'без названия'}" будет удалена безвозвратно.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _safeDBAction(() async {
        await DBHelper.deleteNote(note.id!);
        _reloadNotes();
      }, 'Заметка удалена', 'Ошибка при удалении заметки');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color.fromARGB(25, 103, 80, 164),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isEmpty ? Icons.note_add_outlined : Icons.search_off_outlined,
                size: 48,
                color: const Color.fromARGB(128, 103, 80, 164),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'Пока нет заметок' : 'Ничего не найдено',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Нажмите + чтобы создать первую заметку'
                  : 'Попробуйте изменить поисковый запрос',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои заметки',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 76),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _futureNotes,
              builder: (context, snapshot) {
                // Обработка состояния загрузки
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Обработка ошибок
                if (snapshot.hasError || _hasError) {
                  final error = snapshot.error ?? _lastError ?? 'Неизвестная ошибка';
                  return DataErrorWidget(
                    error: error,
                    onRetry: _reloadNotes,
                    contextMessage: 'Не удалось загрузить заметки. '
                        'Проверьте подключение к базе данных и попробуйте снова.',
                  );
                }

                // Обработка пустого состояния
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // Отображение данных
                final notes = snapshot.data!;

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification &&
                        _searchQuery.isEmpty &&
                        !_isLoadingMore &&
                        _hasMore &&
                        !_hasError) {
                      final metrics = scrollNotification.metrics;
                      if (metrics.extentAfter < 500) {
                        _fetchNotesPaginated();
                      }
                    }
                    return false;
                  },
                  child: Column(
                    children: [
                      // Счетчик заметок
                      if (kDebugMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Загружено заметок: ${notes.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      // Список заметок
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: notes.length + (_isLoadingMore && _searchQuery.isEmpty ? 1 : 0),
                          itemExtent: 100,
                          cacheExtent: 300,
                          addAutomaticKeepAlives: true,
                          itemBuilder: (context, index) {
                            if (index < notes.length) {
                              return _NoteCard(
                                note: notes[index],
                                onEdit: () => _editNote(notes[index]),
                                onDelete: () => _deleteNote(notes[index]),
                              );
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Кнопка для тестирования ошибок (только в debug режиме)
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16),
              child: FloatingActionButton.small(
                heroTag: 'test_error',
                onPressed: () {
                  // Тестируем обработку ошибок
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Тест ошибок'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Выберите тип ошибки для тестирования:'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              throw Exception('Тестовая ошибка Flutter');
                            },
                            child: const Text('Flutter ошибка'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Имитируем ошибку загрузки
                              setState(() {
                                _hasError = true;
                                _lastError = Exception('Тестовая ошибка загрузки');
                                _futureNotes = Future.error(_lastError!);
                              });
                            },
                            child: const Text('Ошибка данных'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.orange,
                child: const Icon(Icons.bug_report),
              ),
            ),

          // Основная кнопка добавления
          FloatingActionButton(
            onPressed: _createNote,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 2,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _NoteEditDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String dialogTitle;

  const _NoteEditDialog({
    required this.titleController,
    required this.bodyController,
    required this.dialogTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dialogTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 1,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Текст заметки',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty ||
                        bodyController.text.trim().isNotEmpty) {
                      Navigator.pop(context, true);
                    } else {
                      // Показываем ошибку валидации
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Заполните хотя бы одно поле'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}