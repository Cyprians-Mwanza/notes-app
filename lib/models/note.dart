import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Note {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  Note({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
