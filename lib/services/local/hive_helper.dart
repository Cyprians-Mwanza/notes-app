import 'package:hive_flutter/hive_flutter.dart';
import '../../models/note.dart';

class HiveHelper {
  static const _boxName = 'notesBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    await Hive.openBox<Note>(_boxName);
  }

  static Box<Note> get box => Hive.box<Note>(_boxName);

  static Future<void> saveNotes(List<Note> notes) async {
    final box = Hive.box<Note>(_boxName);
    await box.clear();
    await box.addAll(notes);
  }

  static List<Note> getNotes() => box.values.toList();

  static Future<void> clear() async => box.clear();
}
