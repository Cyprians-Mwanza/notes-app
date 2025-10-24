import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/note.dart';

class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(NoteAdapter());

    // Open boxes
    await Hive.openBox<Note>(AppConstants.hiveNotesBox);
  }

  static Box<Note> get notesBoxInstance => Hive.box<Note>(AppConstants.hiveNotesBox);

  // Note operations
  static Future<void> saveNote(Note note) async {
    await notesBoxInstance.put(note.id, note);
  }

  static Future<void> saveAllNotes(List<Note> notes) async {
    final Map<dynamic, Note> notesMap = {
      for (var note in notes) note.id: note
    };
    await notesBoxInstance.putAll(notesMap);
  }

  static List<Note> getAllNotes() {
    final notes = notesBoxInstance.values.toList();

    // Sort by ID in descending order (newest first)
    notes.sort((a, b) {
      final aId = int.tryParse(a.id ?? '0') ?? 0;
      final bId = int.tryParse(b.id ?? '0') ?? 0;
      return bId.compareTo(aId); // Descending order (newest first)
    });

    return notes;
  }

  static Note? getNoteById(String id) {
    return notesBoxInstance.get(id);
  }

  static Future<void> deleteNote(String id) async {
    await notesBoxInstance.delete(id);
  }

  // App data operations


  static Future<void> clearAllData() async {
    await notesBoxInstance.clear();
  }
}