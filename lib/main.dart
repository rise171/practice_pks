import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_notes_app/auth.dart';

const supabaseUrl = 'https://zskpppobtuipbhcutrol.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpza3BwcG9idHVpcGJoY3V0cm9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2MzgwMTcsImV4cCI6MjA3NzIxNDAxN30.d_NwPUfKJGfIvXdS0s2pYjwSaah_xdgUHatnwbZ_Adk';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Notes',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
