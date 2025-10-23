import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../data/ remote/api/retrofit/api_client.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../domain/entities/note_entity.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final NoteRepository _noteRepository;

  NoteCubit()
      : _noteRepository = NoteRepository(apiClient: ApiClient(Dio())),
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _noteRepository.createNote(note);
      emit(NoteActionSuccess('Note added successfully.'));
      fetchAllNotes();
    } catch (e) {
      print('NoteCubit - Error adding note: $e');
      emit(NoteError('Failed to add note: $e'));
    }
  }

  Future<void> updateNote(NoteEntity note) async {
    try {
      print('NoteCubit - Updating note: ${note.id}');
      await _noteRepository.updateNote(note);
      emit(NoteActionSuccess('Note updated successfully.'));
      fetchAllNotes();
    } catch (e) {
      print('NoteCubit - Error updating note: $e');
      emit(NoteError('Failed to update note: $e'));
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      print('NoteCubit - Deleting note: $id');
      await _noteRepository.deleteNote(id);
      emit(NoteActionSuccess('Note deleted successfully.'));
      fetchAllNotes();
    } catch (e) {
      print('NoteCubit - Error deleting note: $e');
      emit(NoteError('Failed to delete note: $e'));
    }
  }
}