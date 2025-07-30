import 'package:flutter/material.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/enums/menu_action.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';
import 'package:secondapp/utilities/dialogs/logout_dialog.dart';
import 'package:secondapp/views/login_view_local.dart';
import 'package:secondapp/views/notes/notes_list_view.dart';

class NotesViewLocal extends StatefulWidget {
  const NotesViewLocal({super.key});

  @override
  State<NotesViewLocal> createState() => _NotesViewLocalState();
}

class _NotesViewLocalState extends State<NotesViewLocal> {
  late final HiveNoteStorage _notesService;

  @override
  void initState() {
    _notesService = HiveNoteStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalSession.currentUser;
    if (user == null) {
      return const Center(child: Text('Kein Nutzer eingeloggt'));
    }
    final userId = user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deine Notizen (Lokal)'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNoteHiveView);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    LocalSession.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginViewLocal()),
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Abmelden'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<LocalNote>;
                return NotesListView(
                  notes: allNotes,
                  currentUserId: userId,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.id);
                  },
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNoteHiveView,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
