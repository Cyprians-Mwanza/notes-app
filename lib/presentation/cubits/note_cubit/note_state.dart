import 'package:equatable/equatable.dart';
import '../../../domain/entities/note_entity.dart';

// NoteState - defines all possible states for note management using Equatable for value equality
abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => []; // Equatable requirement for state comparison
}

class NoteInitial extends NoteState {} // Initial state before any note operations

class NoteLoading extends NoteState {} // Loading state during note fetching operations

class NoteLoaded extends NoteState {
  final List<NoteEntity> notes; // Contains the list of notes to display

  const NoteLoaded(this.notes);

  @override
  List<Object?> get props => [notes]; // Equality based on notes list
}

class NoteActionSuccess extends NoteState {
  final String message; // Success message for user feedback after CRUD operations

  const NoteActionSuccess(this.message);

  @override
  List<Object?> get props => [message]; // Equality based on message content
}

class NoteError extends NoteState {
  final String message; // Error message for user feedback when operations fail

  const NoteError(this.message);

  @override
  List<Object?> get props => [message]; // Equality based on error message
}