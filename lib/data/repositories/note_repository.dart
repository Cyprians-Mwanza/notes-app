import 'package:dio/dio.dart';
import '../ remote/api/retrofit/api_client.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository_interface.dart';
import '../local/hive/hive_helper.dart';

class NoteRepository implements NoteRepositoryInterface {
  final ApiClient apiClient;

  NoteRepository({required this.apiClient});

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      // First try to get from local storage
      final localNotes = HiveHelper.getAllNotes();

      if (localNotes.isEmpty) {
        // If no local notes, fetch from API
        try {
          final apiNotes = await apiClient.getNotes();
          final notes = apiNotes.map((note) => NoteEntity(
            id: note.id,
            title: note.title,
            body: note.body,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt,
            isSynced: true,
          )).toList();

          // Save to local storage
          await HiveHelper.saveAllNotes(notes.map((e) => e.toModel()).toList());
          await HiveHelper.setLastSyncTime(DateTime.now());

          return notes;
        } catch (e) {
          // If API fails, return empty list
          return [];
        }
      }

      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    } catch (e) {
      // Fallback to local storage if any error occurs
      final localNotes = HiveHelper.getAllNotes();
      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    }
  }

  @override
  Future<NoteEntity> createNote(NoteEntity note) async {
    try {
      // Save locally first
      final newNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await HiveHelper.saveNote(newNote.toModel());

      // Try to sync with API
      try {
        final apiNote = await apiClient.createNote(newNote.toModel());
        final syncedNote = newNote.copyWith(
          id: apiNote.id,
          isSynced: true,
        );
        await HiveHelper.saveNote(syncedNote.toModel());
        return syncedNote;
      } catch (e) {
        return newNote;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await HiveHelper.saveNote(updatedNote.toModel());

      // Try to sync with API if note was previously synced
      if (note.isSynced && note.id != null) {
        try {
          await apiClient.updateNote(note.id!, updatedNote.toModel());
          final syncedNote = updatedNote.copyWith(isSynced: true);
          await HiveHelper.saveNote(syncedNote.toModel());
          return syncedNote;
        } catch (e) {
          return updatedNote.copyWith(isSynced: false);
        }
      }

      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      await HiveHelper.deleteNote(id);

      // Try to delete from API
      try {
        await apiClient.deleteNote(id);
      } catch (e) {
        // Ignore API deletion errors for now
      }
    } catch (e) {
      rethrow;
    }
  }
}