import 'package:equatable/equatable.dart';
import '../../data/models/note.dart' as model;

// NoteEntity - domain entity representing a note in business logic, free from storage/API concerns
class NoteEntity extends Equatable {
  final String? id; // Note identifier - nullable for new notes before persistence
  final String title; // Note title - guaranteed non-null in business logic
  final String body; // Note content - guaranteed non-null in business logic

  const NoteEntity({
    this.id,
    required this.title,
    required this.body,
  });

  // Convert from data model (Hive) to domain entity - bridges storage and business layers
  factory NoteEntity.fromModel(model.Note note) {
    return NoteEntity(
      id: note.id,
      title: note.title, // Data model already ensures non-null values
      body: note.body,
    );
  }

  // Convert from domain entity to data model (Hive) for local storage
  model.Note toModel() {
    return model.Note(
      id: id,
      title: title, // Entity guarantees non-null values for storage
      body: body,
    );
  }

  // CopyWith pattern for immutable updates - returns new instance with modified fields
  NoteEntity copyWith({
    String? id,
    String? title,
    String? body,
  }) {
    return NoteEntity(
      id: id ?? this.id, // Use new value if provided, otherwise keep current
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [id, title, body]; // Equatable for value-based equality comparisons
}