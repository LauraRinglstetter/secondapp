import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';
import 'package:secondapp/services/remote/couchdb_api.dart';

class CreateUpdateNoteHiveView extends StatefulWidget {
  const CreateUpdateNoteHiveView({super.key});

  @override
  State<CreateUpdateNoteHiveView> createState() => _CreateUpdateNoteHiveViewState();
}

class _CreateUpdateNoteHiveViewState extends State<CreateUpdateNoteHiveView> {
  final _textController = TextEditingController();
  LocalNote? _note;
  final _noteStorage = HiveNoteStorage();
  final _shareController = TextEditingController();
  String? _shareFeedback;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Nur setzen, wenn noch nicht passiert
    if (_note != null) return;

    final maybeNote = ModalRoute.of(context)?.settings.arguments;
    if (maybeNote != null && maybeNote is LocalNote) {
      // Existierende Notiz wurde übergeben
      _note = maybeNote;
    } else {
      // Keine Notiz übergeben → neue erstellen
      _createNewNote();
    }
  }

  Future<void> _createNewNote() async {
    final user = LocalSession.currentUser!;
    final note = await _noteStorage.createNote(ownerUserId: user.id);
    setState(() {
      _note = note;
    });
  }

  Future<void> _addParagraph(String text) async {
    final user = LocalSession.currentUser!;
    final id = _note!.id;

    await _noteStorage.addParagraph(
      noteId: id,
      author: user.email,
      text: text,
    );

    final updated = await _noteStorage.getNoteById(id);
    setState(() {
      _note = updated;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;

    return Scaffold(
      appBar: AppBar(title: const Text('Neue Notiz')),
      body: note == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: note.content.length,
                    itemBuilder: (context, index) {
                      final p = note.content[index];
                      return ListTile(
                        title: Text(p.text),
                        subtitle: Text('${p.author} • ${p.timestamp.toLocal()}'),
                      );
                    },
                  ),
                ),
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
                          await _addParagraph(text);
                        },
                        child: const Text('Absatz hinzufügen'),
                      ),
                      const SizedBox(height: 20),
                        TextField(
                          controller: _shareController,
                          decoration: const InputDecoration(
                            labelText: 'E-Mail-Adresse zum Teilen',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final email = _shareController.text.trim();
                            final couch = CouchDbApi(
                              host: 'http://10.0.2.2:5984',
                              username: 'admin',
                              password: 'admin',
                            );

                            final foundUser = await couch.findUserByEmail(email);

                            if (foundUser == null) {
                              setState(() {
                                _shareFeedback = '❌ Kein registrierter Nutzer mit dieser E-Mail gefunden';
                              });
                              return;
                            }

                            final targetUserId = foundUser['_id'];

                            if (_note != null) {
                              await _noteStorage.shareNoteWithUser(
                                noteId: _note!.id,
                                otherUserId: targetUserId,
                              );
                              setState(() {
                                _shareFeedback = '✅ Notiz geteilt mit $email';
                                _shareController.clear();
                              });
                            }
                          },
                          child: const Text('Teilen'),
                        ),
                        if (_shareFeedback != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _shareFeedback!,
                              style: TextStyle(
                                color: _shareFeedback!.startsWith('✅') ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
