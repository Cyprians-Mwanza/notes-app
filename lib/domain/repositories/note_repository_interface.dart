import '../entities/note_entity.dart';

abstract class NoteRepositoryInterface {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote(NoteEntity note);
  Future<NoteEntity> updateNote(NoteEntity note);
  Future<void> deleteNote(int id);
}