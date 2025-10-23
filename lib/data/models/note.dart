import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Note extends Equatable {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  @HiveField(5)
  final bool isSynced;

  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Note(
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