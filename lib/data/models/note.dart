import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Note extends Equatable {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  const Note({
    this.id,
    required this.title,
    required this.body,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? title,
    String? body,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  List<Object?> get props => [id, title, body];
}