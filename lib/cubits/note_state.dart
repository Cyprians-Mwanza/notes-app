import 'package:equatable/equatable.dart';
import '../models/note.dart';

abstract class NoteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;
  NoteLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NoteAdded extends NoteState {
  final String message;
  NoteAdded([this.message = 'Note added successfully']);

  @override
  List<Object?> get props => [message];
}

class NoteUpdated extends NoteState {
  final String message;
  NoteUpdated([this.message = 'Note updated successfully']);

  @override
  List<Object?> get props => [message];
}

class NoteDeleted extends NoteState {
  final String message;
  NoteDeleted([this.message = 'Note deleted successfully']);

  @override
  List<Object?> get props => [message];
}

class NoteError extends NoteState {
  final String message;
  NoteError(this.message);

  @override
  List<Object?> get props => [message];
}
