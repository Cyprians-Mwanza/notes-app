import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';
import '../../models/user.dart';

class HiveHelper {
  static const _userBox = 'userBox';
  static const _noteBox = 'noteBox';

  /// Initialize Hive and register adapters before use
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    // Register adapters (only once)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Pre-open boxes for faster access
    await Hive.openBox<User>(_userBox);
    await Hive.openBox<Note>(_noteBox);
  }

  // ---------- USER ----------
  Future<void> saveUser(User user) async {
    final box = await Hive.openBox<User>(_userBox);
    await box.put('currentUser', user);
  }

  Future<User?> getUser() async {
    final box = await Hive.openBox<User>(_userBox);
    return box.get('currentUser');
  }

  Future<void> deleteUser() async {
    final box = await Hive.openBox<User>(_userBox);
    await box.delete('currentUser');
  }

  // ---------- NOTES ----------
  Future<void> saveNote(Note note) async {
    final box = await Hive.openBox<Note>(_noteBox);
    await box.put(note.id, note);
  }

  Future<List<Note>> getAllNotes() async {
    final box = await Hive.openBox<Note>(_noteBox);
    return box.values.toList();
  }

  Future<void> updateNote(Note note) async {
    final box = await Hive.openBox<Note>(_noteBox);
    await box.put(note.id, note);
  }

  Future<void> deleteNoteById(String id) async {
    final box = await Hive.openBox<Note>(_noteBox);
    await box.delete(id);
  }

  Future<void> clearNotes() async {
    final box = await Hive.openBox<Note>(_noteBox);
    await box.clear();
  }

  // ---------- SYNC ----------
  Future<void> syncNotes(List<Note> remoteNotes) async {
    final box = await Hive.openBox<Note>(_noteBox);
    await box.clear();
    for (var note in remoteNotes) {
      await box.put(note.id, note);
    }
  }
}
