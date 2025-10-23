import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_edit_note_page.dart';
import 'note_detail_page.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../cubits/note_cubit/note_state.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/auth_cubit/auth_state.dart'; // Add this import
import '../../../domain/entities/note_entity.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NoteCubit>().fetchAllNotes());
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Listen for logout and navigate to login page
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocConsumer<NoteCubit, NoteState>(
          listener: (context, state) {
            if (state is NoteActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is NoteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NoteLoaded) {
              if (state.notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_add, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No notes yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to create your first note',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Updated: ${_formatDate(note.updatedAt)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (!note.isSynced) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.sync_disabled, size: 12, color: Colors.orange),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (note.id != null) {
                            _deleteNote(note.id!);
                          }
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailPage(note: note),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('No notes found.'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditNotePage()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _deleteNote(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NoteCubit>().deleteNote(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}