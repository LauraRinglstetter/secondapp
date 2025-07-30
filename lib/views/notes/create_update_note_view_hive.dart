import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:secondapp/services/cloud/cloud_note.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';
import 'package:secondapp/services/auth/auth_service.dart';
import 'package:hive/hive.dart';

class CreateUpdateNoteHiveView extends StatefulWidget {
  const CreateUpdateNoteHiveView({super.key});

  @override
  State<CreateUpdateNoteHiveView> createState() => _CreateUpdateNoteHiveViewState();
}

class _CreateUpdateNoteHiveViewState extends State<CreateUpdateNoteHiveView> {
  final _textController = TextEditingController();
  CloudNote? _note;
  final _noteStorage = HiveNoteStorage();

  @override
  void initState() {
    super.initState();
    _createNoteIfNeeded();
  }

  Future<void> _createNoteIfNeeded() async {
    final user = AuthService.firebase().currentUser!;
    final note = await _noteStorage.createNote(ownerUserId: user.id);
    setState(() {
      _note = note;
    });
  }

  Future<void> _addParagraph(String text) async {
    final user = AuthService.firebase().currentUser!;
    final box = await Hive.openBox<LocalNote>('notes');
    final localNote = box.get(_note!.documentId);
    if (localNote != null) {
      localNote.content.add(LocalParagraph(
        author: user.email,
        text: text,
        timestamp: DateTime.now(),
      ));
      localNote.lastModified = DateTime.now();
      await localNote.save();

      final updatedNote = CloudNote(
        documentId: localNote.id,
        ownerUserId: localNote.userId,
        content: localNote.content.map((p) => NoteParagraph(
          author: p.author,
          text: p.text,
          timestamp: p.timestamp,
        )).toList(),
        sharedWith: localNote.sharedWith,
      );

      setState(() {
        _note = updatedNote;
        _textController.clear();
      });
    }
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
                // Absatzliste
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

                // Eingabe & Button
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
