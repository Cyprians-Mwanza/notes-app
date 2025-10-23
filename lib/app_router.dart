import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/notes_page.dart';
import 'screens/note_detail_page.dart';
import 'screens/add_edit_note_page.dart';
import 'models/note.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignupPage());
      case '/notes':
        return MaterialPageRoute(builder: (_) => NotesPage());
      case '/add_note':
        return MaterialPageRoute(builder: (_) => AddEditNotePage());
      case '/note_detail':
        final note = settings.arguments as Note;
        return MaterialPageRoute(builder: (_) => NoteDetailPage(note: note));
      default:
        return null;
    }
  }
}
