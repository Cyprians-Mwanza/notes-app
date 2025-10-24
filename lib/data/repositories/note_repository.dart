import '../ remote/api/retrofit/api_client.dart';
import '../ remote/models/api_note.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository_interface.dart';
import '../local/hive/hive_helper.dart';

// Note repository - implements offline-first strategy with local storage primary and background API sync
class NoteRepository implements NoteRepositoryInterface {
  final ApiClient apiClient;

  NoteRepository({required this.apiClient});

  @override
  // Offline-first note retrieval - checks local storage first, falls back to API only if empty
  Future<List<NoteEntity>> getNotes() async {
    try {
      print('NoteRepository - Getting notes...');

      // Always check local storage first for immediate response (offline-first approach)
      final localNotes = HiveHelper.getAllNotes();
      print('NoteRepository - Found ${localNotes.length} local notes');

      // Return local notes immediately if available - user doesn't wait for network
      if (localNotes.isNotEmpty) {
        final entities = localNotes.map((note) => NoteEntity.fromModel(note)).toList();
        print('NoteRepository - Returning ${entities.length} notes from local storage');
        return entities;
      }

      // Only call API if no local data exists (initial app install scenario)
      print('NoteRepository - No local notes, attempting API fetch...');
      try {
        final apiNotes = await apiClient.getNotes();
        print('NoteRepository - Successfully fetched ${apiNotes.length} notes from API');

        if (apiNotes.isEmpty) {
          print('NoteRepository - API returned empty list');
          return [];
        }

        // Convert API notes to app's domain entities and handle null values
        final notes = apiNotes.map((apiNote) {
          return NoteEntity(
            id: apiNote.id?.toString(), // Convert API int IDs to string format
            title: apiNote.title ?? 'No Title', // Provide defaults for null API values
            body: apiNote.body ?? 'No Content',
          );
        }).toList();

        // Save API data to local storage for future offline access
        await HiveHelper.saveAllNotes(notes.map((e) => e.toModel()).toList());
        print('NoteRepository - Saved ${notes.length} notes to local storage');

        return notes;
      } catch (e) {
        print('NoteRepository - API fetch failed: $e');
        // API failure is OK - return empty array since we have no local data
        return [];
      }
    } catch (e) {
      print('NoteRepository - Unexpected error getting notes: $e');
      // Final fallback - return whatever we have in local storage
      final localNotes = HiveHelper.getAllNotes();
      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    }
  }

  @override
  // Create note with immediate local save and background API sync (optimistic updates)
  Future<NoteEntity> createNote(NoteEntity note) async {
    try {
      print('NoteRepository - Creating note: ${note.title}');

      // Generate unique timestamp-based ID for the new note
      final newNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Save to local storage immediately for instant UI response
      await HiveHelper.saveNote(newNote.toModel());
      print('NoteRepository - Note saved locally with ID: ${newNote.id}');

      // Verify the note was actually saved (debugging/validation)
      final savedNote = HiveHelper.getNoteById(newNote.id!);
      print('NoteRepository - Note verification - found in Hive: ${savedNote != null}');

      if (savedNote != null) {
        print('NoteRepository - Saved note title: ${savedNote.title}');
        print('NoteRepository - Saved note body: ${savedNote.body}');
      } else {
        print('NoteRepository - ERROR: Note was not saved to Hive!');
      }

      // Sync to API in background - fire and forget (doesn't block user)
      _syncNoteToApi(newNote);

      return newNote;
    } catch (e) {
      print('NoteRepository - Error creating note: $e');
      rethrow;
    }
  }

  // Background API sync for new notes - failures are logged but don't affect user experience
  void _syncNoteToApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
        // Note: ID is omitted for POST requests (API generates its own ID)
      );

      await apiClient.createNote(apiNote);
      print('NoteRepository - Note synced with API in background');
    } catch (e) {
      print('NoteRepository - Background API sync failed: $e (this is OK)');
      // Silent failure - user doesn't need to know about background sync issues
    }
  }

  @override
  // Update note with immediate local save and background API sync
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      print('NoteRepository - Updating note: ${note.id}');

      // Save to local storage immediately
      await HiveHelper.saveNote(note.toModel());

      // Sync to API in background if we have a valid ID
      if (note.id != null) {
        _updateNoteInApi(note);
      }

      return note;
    } catch (e) {
      print('NoteRepository - Error updating note: $e');
      rethrow;
    }
  }

  // Background API sync for note updates - includes ID conversion from string to int
  void _updateNoteInApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
      );

      // Convert string ID to int for API call (API expects integer IDs)
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
  // Delete note with immediate local removal and background API sync
  Future<void> deleteNote(String id) async {
    try {
      print('NoteRepository - Deleting note: $id');

      // Remove from local storage immediately
      await HiveHelper.deleteNote(id);

      // Sync deletion to API in background
      _deleteNoteFromApi(id);
    } catch (e) {
      print('NoteRepository - Error deleting note: $e');
      rethrow;
    }
  }

  // Background API sync for note deletions - includes ID conversion
  void _deleteNoteFromApi(String id) async {
    try {
      // Convert string ID to int for API call
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