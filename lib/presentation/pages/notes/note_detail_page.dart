import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import '../../../domain/entities/note_entity.dart';
import 'add_edit_note_page.dart';


class NoteDetailPage extends StatelessWidget {
  final NoteEntity note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditNotePage(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Created: ${date_utils.DateUtils.formatDateTime(note.createdAt)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                if (!note.isSynced)
                  const Row(
                    children: [
                      Icon(Icons.sync_disabled, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Not synced',
                        style: TextStyle(fontSize: 14, color: Colors.orange),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${date_utils.DateUtils.formatDateTime(note.updatedAt)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.body,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}