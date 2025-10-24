import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/note.dart';

class HiveHelper {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(AppConstants.hiveNotesBox);
  }

  static Box<Note> get notesBoxInstance => Hive.box<Note>(AppConstants.hiveNotesBox);

  static Future<void> saveNote(Note note) async {
    await notesBoxInstance.put(note.id, note);
  }

  // Batch save multiple notes to database - more efficient than individual saves
  static Future<void> saveAllNotes(List<Note> notes) async {
    final Map<dynamic, Note> notesMap = {
      for (var note in notes) note.id: note // Create map with note IDs as keys
    };
    await notesBoxInstance.putAll(notesMap);
  }

  // Get all notes sorted by ID in descending order (newest notes first)
  static List<Note> getAllNotes() {
    final notes = notesBoxInstance.values.toList();

    // Sort by timestamp-based IDs to show newest notes at the top
    notes.sort((a, b) {
      final aId = int.tryParse(a.id ?? '0') ?? 0;
      final bId = int.tryParse(b.id ?? '0') ?? 0;
      // Descending order for newest first
      return bId.compareTo(aId);
    });

    return notes;
  }

  // Retrieve specific note by its ID - returns null if not found
  static Note? getNoteById(String id) {
    return notesBoxInstance.get(id);
  }

  // Delete note from local database by ID
  static Future<void> deleteNote(String id) async {
    await notesBoxInstance.delete(id);
  }

  // Clear all notes from database - used for logout or data reset
  static Future<void> clearAllData() async {
    await notesBoxInstance.clear();
  }
}