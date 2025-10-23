import 'package:notes_app/services/api/api_client.dart';
import 'package:notes_app/models/note.dart';

class NoteService {
  final ApiClient _apiClient = ApiClient(createDioClient());

  Future<List<Note>> fetchNotes() async {
    final response = await _apiClient.getNotes();
    if (response.response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("Failed to fetch notes: ${response.response.statusCode}");
    }
  }

  Future<void> createNote(Note note) async {
    final response = await _apiClient.createNote(note.toJson());
    if (response.response.statusCode != 200 &&
        response.response.statusCode != 201) {
      throw Exception("Failed to create note");
    }
  }

  Future<void> updateNote(Note note) async {
    final response = await _apiClient.updateNote(note.id, note.toJson());
    if (response.response.statusCode != 200) {
      throw Exception("Failed to update note");
    }
  }

  Future<void> deleteNote(String id) async {
    final response = await _apiClient.deleteNote(id);
    if (response.response.statusCode != 200 &&
        response.response.statusCode != 204) {
      throw Exception("Failed to delete note");
    }
  }
}
