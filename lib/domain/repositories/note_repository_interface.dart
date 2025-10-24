import '../entities/note_entity.dart';

// NoteRepositoryInterface - defines the contract for note data operations (abstraction layer)
abstract class NoteRepositoryInterface {
  Future<List<NoteEntity>> getNotes(); // Retrieve all notes (offline-first implementation)
  Future<NoteEntity> createNote(NoteEntity note); // Create new note with immediate local persistence
  Future<NoteEntity> updateNote(NoteEntity note); // Update existing note with immediate local persistence
  Future<void> deleteNote(String id); // Delete note by ID with immediate local removal
}