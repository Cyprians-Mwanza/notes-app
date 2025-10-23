// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiNote _$ApiNoteFromJson(Map<String, dynamic> json) => ApiNote(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$ApiNoteToJson(ApiNote instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
    };
