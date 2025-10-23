import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../../domain/entities/note_entity.dart';

class AddEditNotePage extends StatefulWidget {
  final NoteEntity? note;
  const AddEditNotePage({super.key, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      if (widget.note == null) {
        // Add new note
        context.read<NoteCubit>().addNote(
          _titleController.text,
          _bodyController.text,
        );
      } else {
        // Update existing note
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text,
          body: _bodyController.text,
        );
        context.read<NoteCubit>().updateNote(updatedNote);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Note Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter note content' : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEditing ? 'Update Note' : 'Save Note'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}