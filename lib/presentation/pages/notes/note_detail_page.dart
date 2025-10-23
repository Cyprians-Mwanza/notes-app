import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../../domain/entities/note_entity.dart';
import '../../cubits/note_cubit/note_state.dart';
import 'add_edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final NoteEntity note;
  const NoteDetailPage({super.key, required this.note});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late NoteEntity _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
  }

  void _editNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNotePage(note: _currentNote),
      ),
    ).then((result) {
      // This callback runs when we return from the edit page
      if (result != null && result is NoteEntity) {
        // Update with the edited note
        setState(() {
          _currentNote = result;
        });
      } else {
        // Refresh from the cubit state to get the latest data
        _refreshNoteFromCubit();
      }
    });
  }

  void _refreshNoteFromCubit() {
    final state = context.read<NoteCubit>().state;
    if (state is NoteLoaded) {
      final updatedNote = state.notes.firstWhere(
            (n) => n.id == _currentNote.id,
        orElse: () => _currentNote,
      );
      if (updatedNote != _currentNote) {
        setState(() {
          _currentNote = updatedNote;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteCubit, NoteState>(
      listener: (context, state) {
        if (state is NoteLoaded) {
          // When notes are loaded/updated, refresh our current note
          final updatedNote = state.notes.firstWhere(
                (n) => n.id == _currentNote.id,
            orElse: () => _currentNote,
          );
          if (updatedNote != _currentNote) {
            setState(() {
              _currentNote = updatedNote;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editNote,
              tooltip: 'Edit Note',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentNote.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _currentNote.body,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}