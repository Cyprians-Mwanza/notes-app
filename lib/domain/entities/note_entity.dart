import 'package:equatable/equatable.dart';
import '../../data/models/note.dart' as model;

class NoteEntity extends Equatable {
  final String? id;
  final String title;
  final String body;

  const NoteEntity({
    this.id,
    required this.title,
    required this.body,
  });

  factory NoteEntity.fromModel(model.Note note) {
    return NoteEntity(
      id: note.id,
      title: note.title,
      body: note.body,
    );
  }

  model.Note toModel() {
    return model.Note(
      id: id,
      title: title,
      body: body,
    );
  }

  NoteEntity copyWith({
    String? id,
    String? title,
    String? body,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [id, title, body];
}