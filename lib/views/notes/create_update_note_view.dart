import 'package:secondapp/services/auth/auth_service.dart';
import 'package:secondapp/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:secondapp/utilities/generics/get_arguments.dart';
import 'package:secondapp/services/cloud/cloud_note.dart';
import 'package:secondapp/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';
import 'package:secondapp/utilities/dialogs/share_note_dialog.dart';


class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService; 
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }


  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {

    final widgetNote = context.getArgument<CloudNote>();

    //if the note already exists and the user is updating this note:
    if(widgetNote != null) {
      _note = widgetNote;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    print('✅ Neue Notiz erstellt: ${newNote.documentId}');
    _note = newNote;
    return newNote;
  }


  @override
  void dispose() {
    //_deleteNoteIfTextIsEmpty();
    //_saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final note = _note;
              //final text = _textController.text;

              if(_note == null || _note!.content.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
                return;
              }
              await showShareNoteDialog(
                context: context,
                onShare: (email) async {
                  try {
                    final exists = await _notesService.userExists(email);
                    if (!exists) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diese E-Mail ist keinem registrierten Nutzer zugeordnet'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    await _notesService.shareNote(
                      noteId: note!.documentId,
                      emailToShareWith: email,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notiz erfolgreich geteilt mit $email'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fehler beim Teilen der Notiz'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }

              );
            }, 
            icon: const Icon(Icons.share))
        ]
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context), 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //_setupTextControllerListener();

              final note = _note!;
              final paragraphs = note.content;

              return Column(
                children: [
                  // Liste der bisherigen Absätze
                  Expanded(
                    child: ListView.builder(
                      itemCount: paragraphs.length,
                      itemBuilder: (context, index) {
                        final p = paragraphs[index];
                        return ListTile(
                          title: Text(p.text),
                          subtitle: Text('${p.author} • ${p.timestamp.toLocal()}'),
                        );
                      },
                    ),
                  ),

                  // Eingabefeld + Button
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Neuen Absatz schreiben...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final text = _textController.text.trim();
                            if (text.isEmpty) return;

                            final user = AuthService.firebase().currentUser!;
                            final paragraph = NoteParagraph(
                              author: user.email,
                              text: text,
                              timestamp: DateTime.now(),
                            );

                            await _notesService.addParagraphToNote(
                              noteId: note.documentId,
                              paragraph: paragraph,
                            );

                            _textController.clear();

                            // Notiz aktualisiert neu laden
                            final updatedNoteSnapshot = await _notesService.notes.doc(note.documentId).get();
                            setState(() {
                              _note = CloudNote.fromDocumentSnapshot(updatedNoteSnapshot);
                            });
                          },
                          child: const Text('Absatz hinzufügen'),
                          
                        )
                      ],
                    ),
                  ),
                ],
              );
              default:
                return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}