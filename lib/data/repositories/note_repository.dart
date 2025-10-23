import 'package:dio/dio.dart';

import '../ remote/api/retrofit/api_client.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository_interface.dart';
import '../local/hive/hive_helper.dart';

class NoteRepository implements NoteRepositoryInterface {
  final ApiClient apiClient;

  NoteRepository({required this.apiClient});

  // Mock data as fallback when API fails
  List<NoteEntity> getMockNotes() {
    final now = DateTime.now();
    return [
      NoteEntity(
        id: 1,
        title: 'Welcome to Notes App',
        body: 'This is your first note. You can edit or delete it, or create new ones using the + button.',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      ),
      NoteEntity(
        id: 2,
        title: 'How to use this app',
        body: '• Tap + to create new notes\n• Tap on a note to view details\n• Swipe or use delete icon to remove notes\n• Your notes are saved locally on your device',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      ),
      NoteEntity(
        id: 3,
        title: 'Offline First',
        body: 'This app works offline! Your notes are stored locally and will sync with the cloud when possible.',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
      ),
    ];
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    try {
      print('NoteRepository - Getting notes...');

      // First try to get from local storage
      final localNotes = HiveHelper.getAllNotes();
      print('NoteRepository - Found ${localNotes.length} local notes');

      if (localNotes.isEmpty) {
        print('NoteRepository - No local notes, fetching from API...');
        // If no local notes, fetch from API
        try {
          final apiNotes = await apiClient.getNotes();
          print('NoteRepository - Fetched ${apiNotes.length} notes from API');

          // Convert API notes to our Note model and add timestamps
          final notes = apiNotes.map((apiNote) {
            final now = DateTime.now();
            // Create a unique ID for local storage since API IDs might conflict
            final localId = DateTime.now().millisecondsSinceEpoch + (apiNote.id ?? 0);

            return NoteEntity(
              id: localId,
              title: apiNote.title ?? 'No Title',
              body: apiNote.body ?? 'No Content',
              createdAt: now,
              updatedAt: now,
              isSynced: true,
            );
          }).toList();

          // Save to local storage
          await HiveHelper.saveAllNotes(notes.map((e) => e.toModel()).toList());
          await HiveHelper.setLastSyncTime(DateTime.now());
          print('NoteRepository - Saved ${notes.length} notes to local storage');

          return notes;
        } catch (e) {
          print('NoteRepository - API fetch failed: $e');

          // If API fails, use mock data for first-time users
          print('NoteRepository - Using mock data as fallback');
          final mockNotes = getMockNotes();
          await HiveHelper.saveAllNotes(mockNotes.map((e) => e.toModel()).toList());
          return mockNotes;
        }
      }

      // Return local notes mapped to entities
      final entities = localNotes.map((note) => NoteEntity.fromModel(note)).toList();
      print('NoteRepository - Returning ${entities.length} notes from local storage');
      return entities;
    } catch (e) {
      print('NoteRepository - Error getting notes: $e');
      // Fallback to local storage if any error occurs
      final localNotes = HiveHelper.getAllNotes();
      if (localNotes.isEmpty) {
        // If even local storage is empty, return mock data
        return getMockNotes();
      }
      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    }
  }

  @override
  Future<NoteEntity> createNote(NoteEntity note) async {
    try {
      print('NoteRepository - Creating note: ${note.title}');

      // Save locally first
      final newNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await HiveHelper.saveNote(newNote.toModel());
      print('NoteRepository - Note saved locally with ID: ${newNote.id}');

      // Try to sync with API (but don't fail if API is unavailable)
      try {
        final apiNote = await apiClient.createNote(newNote.toModel());
        final syncedNote = newNote.copyWith(
          id: apiNote.id ?? newNote.id,
          isSynced: true,
        );
        await HiveHelper.saveNote(syncedNote.toModel());
        print('NoteRepository - Note synced with API');
        return syncedNote;
      } catch (e) {
        print('NoteRepository - API sync failed: $e');
        return newNote.copyWith(isSynced: false);
      }
    } catch (e) {
      print('NoteRepository - Error creating note: $e');
      rethrow;
    }
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      print('NoteRepository - Updating note: ${note.id}');

      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await HiveHelper.saveNote(updatedNote.toModel());

      // Try to sync with API if note was previously synced
      if (note.isSynced && note.id != null) {
        try {
          await apiClient.updateNote(note.id!, updatedNote.toModel());
          final syncedNote = updatedNote.copyWith(isSynced: true);
          await HiveHelper.saveNote(syncedNote.toModel());
          print('NoteRepository - Note updated on API');
          return syncedNote;
        } catch (e) {
          print('NoteRepository - API update failed: $e');
          return updatedNote.copyWith(isSynced: false);
        }
      }

      return updatedNote;
    } catch (e) {
      print('NoteRepository - Error updating note: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(int id) async {
    try {
      print('NoteRepository - Deleting note: $id');
      await HiveHelper.deleteNote(id);

      // Try to delete from API (but don't fail if API is unavailable)
      try {
        await apiClient.deleteNote(id);
        print('NoteRepository - Note deleted from API');
      } catch (e) {
        print('NoteRepository - API deletion failed: $e');
        // Ignore API deletion errors
      }
    } catch (e) {
      print('NoteRepository - Error deleting note: $e');
      rethrow;
    }
  }
}