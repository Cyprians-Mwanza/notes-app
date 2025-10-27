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
      final notes = await _noteRepository.getNotes();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to fetch notes: $e'));
    }
  }

  Future<void> addNote(String title, String body) async {
    try {
      final note = NoteEntity(title: title, body: body);
      await _noteRepository.createNote(note);
      emit(const NoteActionSuccess('Note added successfully.'));
    } catch (e) {
      emit(NoteError('Failed to add note: $e'));
    }
  }

  Future<void> updateNote(NoteEntity note) async {
    try {
      await _noteRepository.updateNote(note);
      emit(const NoteActionSuccess('Note updated successfully.'));
    } catch (e) {
      emit(NoteError('Failed to update note: $e'));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _noteRepository.deleteNote(id);
      emit(const NoteActionSuccess('Note deleted successfully.'));
    } catch (e) {
      emit(NoteError('Failed to delete note: $e'));
    }
  }
}
