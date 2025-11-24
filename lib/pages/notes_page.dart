import 'dart:async';
import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import './notes_page_details.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesRepository repo;
  final List<Note> _items = [];
  final List<Note> _filteredItems = [];
  int _page = 1;
  bool _canLoadMore = true;
  bool _loading = false;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final client = ApiClient(baseUrl: 'https://jsonplaceholder.typicode.com');
    repo = NotesRepository(client);
    _loadMore();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearchQuery = query;
      _page = 1;
      _canLoadMore = true;
      _items.clear();
      _filteredItems.clear();
    });
    _loadMore();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _page = 1;
      _canLoadMore = true;
      _items.clear();
      _filteredItems.clear();
    });

    try {
      final batch = await repo.list(
          page: 1,
          limit: 20,
          searchQuery: _currentSearchQuery.isEmpty ? null : _currentSearchQuery
      );
      setState(() {
        _items.addAll(batch);
        _filteredItems.addAll(batch);
        _canLoadMore = batch.length == 20;
        _page = 2;
      });
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_canLoadMore || _loading) return;

    setState(() => _loading = true);

    try {
      final batch = await repo.list(
          page: _page,
          limit: 20,
          searchQuery: _currentSearchQuery.isEmpty ? null : _currentSearchQuery
      );
      setState(() {
        _items.addAll(batch);
        _filteredItems.addAll(batch);
        _canLoadMore = batch.isNotEmpty;
        if (_canLoadMore) _page++;
      });
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCreateNoteDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Новая заметка'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Содержание',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final body = bodyController.text.trim();

              if (title.isEmpty || body.isEmpty) {
                _showErrorSnackbar('Заполните все поля');
                return;
              }

              try {
                final newNote = await repo.create(title, body);
                setState(() {
                  _items.insert(0, newNote);
                  _filteredItems.insert(0, newNote);
                });
                Navigator.of(context).pop();
                _showSuccessSnackbar('Заметка создана (демо)');
              } catch (e) {
                _showErrorSnackbar('Ошибка создания: $e');
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    final note = _filteredItems[index];
    final deletedNote = note;

    setState(() {
      _items.remove(note);
      _filteredItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Заметка удалена'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Отменить',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _items.insert(0, deletedNote);
              _filteredItems.insert(index, deletedNote);
            });
          },
        ),
      ),
    );

    //Демонстрационный вызов API
    repo.delete(note.id).catchError((e) {
      print('Ошибка удаления на сервере: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои Заметки',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          //Поисковая строка
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _currentSearchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredItems.isEmpty && _loading) {
      return _buildLoadingIndicator();
    }

    if (_filteredItems.isEmpty && !_loading) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          if (_currentSearchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Результаты поиска: ${_filteredItems.length} заметок',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length + (_canLoadMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _filteredItems.length) {
                  if (_canLoadMore) {
                    _loadMore();
                    return _buildLoadingMoreIndicator();
                  }
                  return _buildEndOfList();
                }
                return _buildNoteItem(_filteredItems[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _currentSearchQuery.isEmpty
                ? 'Загружаем заметки...'
                : 'Ищем заметки...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _currentSearchQuery.isEmpty
                ? 'Заметок пока нет'
                : 'Ничего не найдено',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _currentSearchQuery.isEmpty
                ? 'Создайте первую заметку'
                : 'Попробуйте изменить запрос',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Все заметки загружены',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(Note note, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              note.id.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          note.title,
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
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Пользователь #${note.userId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.grey[600],
          ),
          onPressed: () => _deleteNote(index),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailsPage(id: note.id, repo: repo),
          ),
        ),
      ),
    );
  }
}