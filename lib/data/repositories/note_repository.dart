import '../ remote/api/retrofit/api_client.dart';
import '../ remote/models/api_note.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository_interface.dart';
import '../local/hive/hive_helper.dart';

class NoteRepository implements NoteRepositoryInterface {
  final ApiClient apiClient;

  NoteRepository({required this.apiClient});

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      print('NoteRepository - Getting notes...');

      // Always try local storage first (offline-first approach)
      final localNotes = HiveHelper.getAllNotes();
      print('NoteRepository - Found ${localNotes.length} local notes');

      // If we have local notes, return them immediately
      if (localNotes.isNotEmpty) {
        final entities = localNotes.map((note) => NoteEntity.fromModel(note)).toList();
        print('NoteRepository - Returning ${entities.length} notes from local storage');
        return entities;
      }

      // Only try API if no local notes exist
      print('NoteRepository - No local notes, attempting API fetch...');
      try {
        final apiNotes = await apiClient.getNotes();
        print('NoteRepository - Successfully fetched ${apiNotes.length} notes from API');

        if (apiNotes.isEmpty) {
          print('NoteRepository - API returned empty list');
          return [];
        }

        // Convert API notes to our Note model
        final notes = apiNotes.map((apiNote) {
          return NoteEntity(
            id: apiNote.id?.toString(), // Convert API int id to String
            title: apiNote.title ?? 'No Title',
            body: apiNote.body ?? 'No Content',
          );
        }).toList();

        // Save to local storage for future use
        await HiveHelper.saveAllNotes(notes.map((e) => e.toModel()).toList());
        print('NoteRepository - Saved ${notes.length} notes to local storage');

        return notes;
      } catch (e) {
        print('NoteRepository - API fetch failed: $e');
        // API failed, but that's OK - we'll work with empty local storage
        // User can create their own notes
        return [];
      }
    } catch (e) {
      print('NoteRepository - Unexpected error getting notes: $e');
      // Final fallback - return whatever is in local storage
      final localNotes = HiveHelper.getAllNotes();
      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    }
  }

  @override
  Future<NoteEntity> createNote(NoteEntity note) async {
    try {
      print('NoteRepository - Creating note: ${note.title}');

      // Generate a unique ID for the new note
      final newNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Save to local storage immediately
      await HiveHelper.saveNote(newNote.toModel());
      print('NoteRepository - Note saved locally with ID: ${newNote.id}');

      // Verify the note was saved by reading it back
      final savedNote = HiveHelper.getNoteById(newNote.id!);
      print('NoteRepository - Note verification - found in Hive: ${savedNote != null}');

      if (savedNote != null) {
        print('NoteRepository - Saved note title: ${savedNote.title}');
        print('NoteRepository - Saved note body: ${savedNote.body}');
      } else {
        print('NoteRepository - ERROR: Note was not saved to Hive!');
      }

      // Try to sync with API in background (don't await or block on this)
      _syncNoteToApi(newNote);

      return newNote;
    } catch (e) {
      print('NoteRepository - Error creating note: $e');
      rethrow;
    }
  }

  // Background sync method - doesn't block the UI
  void _syncNoteToApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
      );

      await apiClient.createNote(apiNote);
      print('NoteRepository - Note synced with API in background');
    } catch (e) {
      print('NoteRepository - Background API sync failed: $e (this is OK)');
      // Silently fail - user doesn't need to know about background sync failures
    }
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      print('NoteRepository - Updating note: ${note.id}');

      // Save to local storage immediately
      await HiveHelper.saveNote(note.toModel());

      // Try to sync with API in background
      if (note.id != null) {
        _updateNoteInApi(note);
      }

      return note;
    } catch (e) {
      print('NoteRepository - Error updating note: $e');
      rethrow;
    }
  }

  void _updateNoteInApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
      );

      // Convert string ID to int for API call, use 0 if conversion fails
      final int? apiId = int.tryParse(note.id!);
      if (apiId != null) {
        await apiClient.updateNote(apiId, apiNote);
        print('NoteRepository - Note updated in API in background');
      } else {
        print('NoteRepository - Cannot update in API: Invalid ID format');
      }
    } catch (e) {
      print('NoteRepository - Background API update failed: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      print('NoteRepository - Deleting note: $id');

      // Delete from local storage immediately
      await HiveHelper.deleteNote(id);

      // Try to delete from API in background
      _deleteNoteFromApi(id);
    } catch (e) {
      print('NoteRepository - Error deleting note: $e');
      rethrow;
    }
  }

  void _deleteNoteFromApi(String id) async {
    try {
      // Convert string ID to int for API call, use 0 if conversion fails
      final int? apiId = int.tryParse(id);
      if (apiId != null) {
        await apiClient.deleteNote(apiId);
        print('NoteRepository - Note deleted from API in background');
      } else {
        print('NoteRepository - Cannot delete from API: Invalid ID format');
      }
    } catch (e) {
      print('NoteRepository - Background API deletion failed: $e');
    }
  }
}