import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/hive/hive_helper.dart';
import 'add_edit_note_page.dart';
import 'note_detail_page.dart';
import '../../cubits/note_cubit/note_cubit.dart';
import '../../cubits/note_cubit/note_state.dart';
import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../cubits/auth_cubit/auth_state.dart';

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

  void _refreshNotes() {
    context.read<NoteCubit>().fetchAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
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
              icon: const Icon(Icons.refresh),
              onPressed: _refreshNotes,
              tooltip: 'Refresh Notes',
            ),
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
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
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
            // Handle NoteActionSuccess by showing the previous loaded state
            if (state is NoteActionSuccess) {
              // Try to get the previous loaded state from cubit
              final cubit = context.read<NoteCubit>();
              // This is a workaround - we'll refetch to ensure consistency
              Future.microtask(() => cubit.fetchAllNotes());
              return const Center(child: CircularProgressIndicator());
            }

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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshNotes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Loading Again'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _refreshNotes();
                },
                child: ListView.builder(
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
                        subtitle: Text(
                          note.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                ),
              );
            } else if (state is NoteError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading notes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshNotes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        // Add this to your floatingActionButton in NotesPage:
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // Debug: Print all notes from Hive
                final notes = HiveHelper.getAllNotes();
                print('=== DEBUG: All notes in Hive ===');
                print('Total notes: ${notes.length}');
                for (var note in notes) {
                  print('Note: ${note.id} - "${note.title}" - "${note.body}"');
                }
                print('=== END DEBUG ===');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Found ${notes.length} notes in Hive. Check console.'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Icon(Icons.bug_report),
              heroTag: 'debug',
              mini: true,
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditNotePage()),
              ),
              child: const Icon(Icons.add),
              heroTag: 'add',
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote(String id) {
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