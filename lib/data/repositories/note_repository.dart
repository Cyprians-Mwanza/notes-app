import 'package:flutter/material.dart';

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

      final localNotes = HiveHelper.getAllNotes();

      if (localNotes.isNotEmpty) {
        final entities = localNotes.map((note) => NoteEntity.fromModel(note)).toList();
        return entities;
      }
      try {
        final apiNotes = await apiClient.getNotes();
        if (apiNotes.isEmpty) {
          return [];
        }

        final notes = apiNotes.map((apiNote) {
          return NoteEntity(
            id: apiNote.id?.toString(),
            title: apiNote.title ?? 'No Title',
            body: apiNote.body ?? 'No Content',
          );
        }).toList();

        await HiveHelper.saveAllNotes(notes.map((e) => e.toModel()).toList());

        return notes;
      } catch (e) {

        return [];
      }
    } catch (e) {
      final localNotes = HiveHelper.getAllNotes();
      return localNotes.map((note) => NoteEntity.fromModel(note)).toList();
    }
  }

  @override
  Future<NoteEntity> createNote(NoteEntity note) async {
    try {

      final newNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await HiveHelper.saveNote(newNote.toModel());
      final savedNote = HiveHelper.getNoteById(newNote.id!);

      if (savedNote != null) {
      } else {
      }
      _syncNoteToApi(newNote);

      return newNote;
    } catch (e) {
      rethrow;
    }
  }
  void _syncNoteToApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
      );
      await apiClient.createNote(apiNote);
    } catch (e) {
      debugPrint('Error syncing note: $e');
    }
  }



  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    try {
      await HiveHelper.saveNote(note.toModel());

      if (note.id != null) {
        _updateNoteInApi(note);
      }

      return note;
    } catch (e) {
      rethrow;
    }
  }

  void _updateNoteInApi(NoteEntity note) async {
    try {
      final apiNote = ApiNote(
        title: note.title,
        body: note.body,
      );

      final int? apiId = int.tryParse(note.id!);
      if (apiId != null) {
        await apiClient.updateNote(apiId, apiNote);
      } else {
        debugPrint(' Could not update note: Invalid API ID (${note.id})');
      }
    } catch (e, stack) {
      debugPrint('Failed to update note in API: $e');
      debugPrint('Stack trace: $stack');
    }
  }


  @override
  Future<void> deleteNote(String id) async {
    try {
      await HiveHelper.deleteNote(id);

      _deleteNoteFromApi(id);
    } catch (e) {
      rethrow;
    }
  }

  void _deleteNoteFromApi(String id) async {
    try {
      final int? apiId = int.tryParse(id);
      if (apiId != null) {
        await apiClient.deleteNote(apiId);
      } else {
        debugPrint('Could not delete note: Invalid API ID ($id)');
      }
    } catch (e, stack) {
      debugPrint('Failed to delete note from API: $e');
      debugPrint('Stack trace: $stack');
    }
  }

}