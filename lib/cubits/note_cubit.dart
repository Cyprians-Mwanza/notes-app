import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/api/note_service.dart';
import '../services/local/hive_helper.dart';
import 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final HiveHelper _hiveHelper = HiveHelper();
  final NoteService _noteService = NoteService();
  final _uuid = const Uuid();

  NoteCubit() : super(NoteInitial());

  Future<void> fetchAllNotes() async {
    emit(NoteLoading());
    try {
      // Load local notes first (offline-first)
      final localNotes = await _hiveHelper.getAllNotes();
      emit(NoteLoaded(localNotes));

      // Try syncing with remote (optional)
      try {
        final remoteNotes = await _noteService.fetchNotes();
        await _hiveHelper.syncNotes(remoteNotes);
        emit(NoteLoaded(await _hiveHelper.getAllNotes()));
      } catch (_) {
        // ignore remote errors, fallback to local
      }
    } catch (e) {
      emit(NoteError("Failed to load notes: $e"));
    }
  }

  Future<void> addNote(String title, String body) async {
    try {
      final note = Note(
        id: _uuid.v4(),
        title: title,
        body: body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _hiveHelper.saveNote(note);

      // Optional remote sync
      try {
        await _noteService.createNote(note);
      } catch (_) {}

      emit(NoteAdded());
      await fetchAllNotes();
    } catch (e) {
      emit(NoteError("Failed to add note: $e"));
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _hiveHelper.updateNote(updatedNote);

      // Optional remote sync
      try {
        await _noteService.updateNote(updatedNote);
      } catch (_) {}

      emit(NoteUpdated());
      await fetchAllNotes();
    } catch (e) {
      emit(NoteError("Failed to update note: $e"));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _hiveHelper.deleteNoteById(id);

      // Optional remote sync
      try {
        await _noteService.deleteNote(id);
      } catch (_) {}

      emit(NoteDeleted());
      await fetchAllNotes();
    } catch (e) {
      emit(NoteError("Failed to delete note: $e"));
    }
  }
}
