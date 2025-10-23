import 'package:json_annotation/json_annotation.dart';

part 'api_note.g.dart';

@JsonSerializable()
class ApiNote {
  final int? id;
  final String? title;
  final String? body;

  ApiNote({
    this.id,
    this.title,
    this.body,
  });

  factory ApiNote.fromJson(Map<String, dynamic> json) => _$ApiNoteFromJson(json);
  Map<String, dynamic> toJson() => _$ApiNoteToJson(this);
}