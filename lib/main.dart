import 'package:flutter/material.dart';
import 'models/note.dart';
import 'edit_note_page.dart';

void main() => runApp(const SimpleNotesApp());

class SimpleNotesApp extends StatelessWidget {
  const SimpleNotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes',
      theme: ThemeData(useMaterial3: true),
      home: const NotesPage(),
        debugShowCheckedModeBanner: false
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [
    Note(id: '1', title: 'Пример', body: 'Это пример заметки'),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) =>
        note.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Future<void> _addNote() async {
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage()),
    );
    if (newNote != null) {
      setState(() => _notes.add(newNote));
    }
  }

  Future<void> _edit(Note note) async {
    final updated = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (_) => EditNotePage(existing: note)),
    );
    if (updated != null) {
      setState(() {
        final i = _notes.indexWhere((n) => n.id == updated.id);
        if (i != -1) _notes[i] = updated;
      });
    }
  }

  void _delete(Note note) {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заметка удалена')),
    );
  }

  void _deleteWithSwipe(Note note) {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    //SnackBar с возможностью отмены
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Заметка удалена'),
        action: SnackBarAction(
          label: 'ОТМЕНА',
          onPressed: () {
            setState(() => _notes.add(note));
          },
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text('Simple Notes'),
          color: Colors.purple[100],
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Поиск по заголовку...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
      body: _filteredNotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.note_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Пока нет заметок. Нажмите +'
                  : 'Заметки не найдены',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _filteredNotes.length,
        itemBuilder: (context, i) {
          final note = _filteredNotes[i];
          return Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return true;
            },
            onDismissed: (direction) {
              _deleteWithSwipe(note);
            },
            child: ListTile(
              leading: Container(
                width: 4,
                height: double.infinity,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              title: Text(
                note.title.isEmpty ? '(без названия)' : note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () => _edit(note),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(note),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}