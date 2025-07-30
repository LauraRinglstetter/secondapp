import 'package:flutter/material.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';

class CreateUpdateNoteHiveView extends StatefulWidget {
  const CreateUpdateNoteHiveView({super.key});

  @override
  State<CreateUpdateNoteHiveView> createState() => _CreateUpdateNoteHiveViewState();
}

class _CreateUpdateNoteHiveViewState extends State<CreateUpdateNoteHiveView> {
  final _textController = TextEditingController();
  LocalNote? _note;
  final _noteStorage = HiveNoteStorage();

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
      appBar: AppBar(title: const Text('Lokale Notiz (Hive)')),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
