import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/ remote/api/retrofit/api_client.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../domain/entities/note_entity.dart';
import 'note_state.dart';

// NoteCubit - manages note-related state and coordinates CRUD operations with optimistic UI updates
class NoteCubit extends Cubit<NoteState> {
  final NoteRepository _noteRepository;

  NoteCubit()
      : _noteRepository = NoteRepository(apiClient: ApiClient.create()),
        super(NoteInitial()); // Start with initial state

  // Fetch all notes from repository (uses offline-first strategy internally)
  Future<void> fetchAllNotes() async {
    emit(NoteLoading()); // Show loading state
    try {
      print('NoteCubit - Fetching all notes...');
      final notes = await _noteRepository.getNotes(); // Repository handles local/API logic
      print('NoteCubit - Fetched ${notes.length} notes');
      emit(NoteLoaded(notes)); // Update state with fetched notes
    } catch (e) {
      print('NoteCubit - Error fetching notes: $e');
      emit(NoteError('Failed to fetch notes: $e')); // Show error state
    }
  }

  // Add new note with optimistic UI update - shows note immediately without waiting for API
  Future<void> addNote(String title, String body) async {
    try {
      print('NoteCubit - Adding note: $title');
      final note = NoteEntity(
        title: title,
        body: body,
      );
      final newNote = await _noteRepository.createNote(note); // Repository handles local save + background sync

      // Optimistic UI update - add new note to top of list immediately
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = [newNote, ...currentState.notes]; // Add new note at beginning
        emit(NoteLoaded(updatedNotes)); // Update UI with new note immediately
      } else {
        await fetchAllNotes(); // Fallback if not in loaded state
      }

      emit(NoteActionSuccess('Note added successfully.')); // Show success message

    } catch (e) {
      print('NoteCubit - Error adding note: $e');
      emit(NoteError('Failed to add note: $e'));
    }
  }

  // Update existing note with optimistic UI update
  Future<void> updateNote(NoteEntity note) async {
    try {
      print('NoteCubit - Updating note: ${note.id}');
      final updatedNote = await _noteRepository.updateNote(note);

      // Optimistic UI update - replace old note with updated version
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = currentState.notes.map((n) => n.id == updatedNote.id ? updatedNote : n).toList();
        emit(NoteLoaded(updatedNotes)); // Update UI with modified note immediately
      } else {
        await fetchAllNotes(); // Fallback if not in loaded state
      }

      emit(NoteActionSuccess('Note updated successfully.'));
    } catch (e) {
      print('NoteCubit - Error updating note: $e');
      emit(NoteError('Failed to update note: $e'));
    }
  }

  // Delete note with optimistic UI update - removes note immediately without waiting for API
  Future<void> deleteNote(String id) async {
    try {
      print('NoteCubit - Deleting note: $id');
      await _noteRepository.deleteNote(id);

      // Optimistic UI update - remove note from list immediately
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = currentState.notes.where((n) => n.id != id).toList();
        emit(NoteLoaded(updatedNotes)); // Update UI without deleted note immediately
      } else {
        await fetchAllNotes(); // Fallback if not in loaded state
      }

      emit(NoteActionSuccess('Note deleted successfully.'));
    } catch (e) {
      print('NoteCubit - Error deleting note: $e');
      emit(NoteError('Failed to delete note: $e'));
    }
  }
}