import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}
class _NotesPageState extends State<NotesPage> {
  late final Stream<List<Map<String, dynamic>>> _notesStream;
  final Map<String, Map<String, dynamic>> _pendingDeletions = {};
  @override
  void initState() {
    super.initState();
    final uid = supabase.auth.currentUser!.id;
    _notesStream = supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false);
  }
  Future<void> _createNote(String title, String content, String imageUrl) async {
    final uid = supabase.auth.currentUser!.id;
    await supabase.from('notes').insert({
      'user_id': uid,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  Future<void> _updateNote(String id, String title, String content, String imageUrl) async {
    await supabase.from('notes').update({
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> _deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
    _pendingDeletions.remove(id);
  }

  Future<String> _uploadImage(File imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from('note-images').upload(fileName, imageFile);
    return supabase.storage.from('note-images').getPublicUrl(fileName);
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }

  void _openCreateDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новая заметка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Заголовок'),
              ),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Текст'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              if (selectedImage != null)
                Column(
                  children: [
                    Image.file(selectedImage!, height: 100, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setDialogState(() => selectedImage = null),
                      child: const Text('Удалить изображение'),
                    ),
                  ],
                ),

              if (selectedImage == null)
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await _pickImage();
                    if (image != null) {
                      setDialogState(() => selectedImage = image);
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Добавить изображение'),
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
                String imageUrl = '';
                if (selectedImage != null) {
                  imageUrl = await _uploadImage(selectedImage!);
                }
                await _createNote(
                  titleCtrl.text.trim(),
                  contentCtrl.text.trim(),
                  imageUrl,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
  void _openEditDialog(Map<String, dynamic> note) {
    final titleCtrl = TextEditingController(text: note['title'] ?? '');
    final contentCtrl = TextEditingController(text: note['content'] ?? '');
    String currentImageUrl = note['image_url'] ?? '';
    File? selectedImage;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Редактировать'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Заголовок'),
              ),
              TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Текст'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              if (currentImageUrl.isNotEmpty)
                Column(
                  children: [
                    Image.network(currentImageUrl, height: 100, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setDialogState(() => currentImageUrl = ''),
                      child: const Text('Удалить изображение'),
                    ),
                  ],
                ),

              if (selectedImage != null)
                Column(
                  children: [
                    Image.file(selectedImage!, height: 100, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setDialogState(() => selectedImage = null),
                      child: const Text('Удалить новое изображение'),
                    ),
                  ],
                ),

              if (currentImageUrl.isEmpty && selectedImage == null)
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await _pickImage();
                    if (image != null) {
                      setDialogState(() => selectedImage = image);
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Добавить изображение'),
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
                String imageUrl = currentImageUrl;
                if (selectedImage != null) {
                  imageUrl = await _uploadImage(selectedImage!);
                }
                await _updateNote(
                  note['id'],
                  titleCtrl.text.trim(),
                  contentCtrl.text.trim(),
                  imageUrl,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Обновить'),
            ),
          ],
        ),
      ),
    );
  }
  void _deleteNoteWithUndo(Map<String, dynamic> note) {
    final noteId = note['id'];
    _pendingDeletions[noteId] = Map<String, dynamic>.from(note);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Заметка удалена'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'ОТМЕНИТЬ',
          onPressed: () {
            _pendingDeletions.remove(noteId);
            setState(() {});
          },
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      if (_pendingDeletions.containsKey(noteId)) {
        _deleteNote(noteId);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Ошибка загрузки'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notes = snapshot.data!
              .where((note) => !_pendingDeletions.containsKey(note['id']))
              .toList();
          if (notes.isEmpty) return const Center(child: Text('Пока нет заметок'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = notes[i];
              return Dismissible(
                key: ValueKey(n['id']),
                background: Container(color: Colors.red.withOpacity(.1)),
                onDismissed: (_) => _deleteNoteWithUndo(n),
                child: Card(
                  child: ListTile(
                    title: Text(n['title'] ?? '(без названия)', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (n['content'] != null && n['content'].isNotEmpty)
                          Text(n['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (n['image_url'] != null && n['image_url'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  n['image_url']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _openEditDialog(n),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteNoteWithUndo(n),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}