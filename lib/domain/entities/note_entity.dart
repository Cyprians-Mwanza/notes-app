import 'package:equatable/equatable.dart';
import '../../data/models/note.dart' as model;

class NoteEntity extends Equatable {
  final int? id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const NoteEntity({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory NoteEntity.fromModel(model.Note note) {
    return NoteEntity(
      id: note.id,
      title: note.title,
      body: note.body,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isSynced: note.isSynced,
    );
  }

  model.Note toModel() {
    return model.Note(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  NoteEntity copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [id, title, body, createdAt, updatedAt, isSynced];
}