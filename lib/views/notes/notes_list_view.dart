import 'package:firstapp/services/cloud/cloud_note.dart';
import 'package:firstapp/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  final String currentUserId;

  const NotesListView({
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.currentUserId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.content.isNotEmpty ? note.content.last.text : '[Keine Inhalte]',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: note.sharedWith.isNotEmpty
            ? Text(
                'Geteilt mit: ${note.sharedWith.join(', ')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
                
              }
            },
            icon: const Icon(Icons.delete),
          )
        );
      },
    );
  }
}
