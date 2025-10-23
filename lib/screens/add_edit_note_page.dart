import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/note_state.dart';
import '../models/note.dart';
import '../cubits/note_cubit.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({this.note, super.key});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!.title;
      _bodyCtrl.text = widget.note!.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Note' : 'Add Note')),
      body: BlocConsumer<NoteCubit, dynamic>(
        listener: (context, state) {
          if (state is NoteError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyCtrl,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Note'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Enter note text' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (isEditing) {
                          await context.read<NoteCubit>().updateNote(
                            widget.note!.copyWith(
                              title: _titleCtrl.text.trim(),
                              body: _bodyCtrl.text.trim(),
                            ),
                          );
                        } else {
                          await context
                              .read<NoteCubit>()
                              .addNote(_titleCtrl.text, _bodyCtrl.text);
                        }
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(isEditing ? 'Update Note' : 'Add Note'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
