import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/ remote/api/retrofit/api_client.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../domain/entities/note_entity.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final NoteRepository _noteRepository;

  NoteCubit()
      : _noteRepository = NoteRepository(apiClient: ApiClient.create()),
        super(NoteInitial());

  Future<void> fetchAllNotes() async {
    emit(NoteLoading());
    try {
      print('NoteCubit - Fetching all notes...');
      final notes = await _noteRepository.getNotes();
      print('NoteCubit - Fetched ${notes.length} notes');
      emit(NoteLoaded(notes));
    } catch (e) {
      print('NoteCubit - Error fetching notes: $e');
      emit(NoteError('Failed to fetch notes: $e'));
    }
  }

  Future<void> addNote(String title, String body) async {
    try {
      print('NoteCubit - Adding note: $title');
      final note = NoteEntity(
        title: title,
        body: body,
      );
      final newNote = await _noteRepository.createNote(note);

      // Get current state and update it
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = [newNote, ...currentState.notes];
        emit(NoteLoaded(updatedNotes));
      } else {
        // If not in loaded state, fetch all notes to refresh
        await fetchAllNotes();
      }

      // Show success message without changing the main state
      emit(NoteActionSuccess('Note added successfully.'));

    } catch (e) {
      print('NoteCubit - Error adding note: $e');
      emit(NoteError('Failed to add note: $e'));
    }
  }

  Future<void> updateNote(NoteEntity note) async {
    try {
      print('NoteCubit - Updating note: ${note.id}');
      final updatedNote = await _noteRepository.updateNote(note);

      // Update UI immediately
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = currentState.notes.map((n) => n.id == updatedNote.id ? updatedNote : n).toList();
        emit(NoteLoaded(updatedNotes));
      } else {
        await fetchAllNotes();
      }

      emit(NoteActionSuccess('Note updated successfully.'));
    } catch (e) {
      print('NoteCubit - Error updating note: $e');
      emit(NoteError('Failed to update note: $e'));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      print('NoteCubit - Deleting note: $id');
      await _noteRepository.deleteNote(id);

      // Update UI immediately
      if (state is NoteLoaded) {
        final currentState = state as NoteLoaded;
        final updatedNotes = currentState.notes.where((n) => n.id != id).toList();
        emit(NoteLoaded(updatedNotes));
      } else {
        await fetchAllNotes();
      }

      emit(NoteActionSuccess('Note deleted successfully.'));
    } catch (e) {
      print('NoteCubit - Error deleting note: $e');
      emit(NoteError('Failed to delete note: $e'));
    }
  }
}