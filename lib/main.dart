import 'package:flutter/material.dart';
import 'pages/notes_page.dart';

void main() => runApp(const ApiNotesApp());

class ApiNotesApp extends StatelessWidget {
  const ApiNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Notes Feed',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      home: const NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}