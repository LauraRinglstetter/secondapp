import 'package:hive/hive.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:uuid/uuid.dart';
import '../local/local_note.dart';
import 'note_storage_interface.dart';

class HiveNoteStorage implements NoteStorage {
  static const String boxName = 'notes';

  Future<Box<LocalNote>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      Hive.registerAdapter(LocalNoteAdapter());
      Hive.registerAdapter(LocalParagraphAdapter()); // Wichtig!
      await Hive.openBox<LocalNote>(boxName);
    }
    return Hive.box<LocalNote>(boxName);
  }

  @override
  Future<LocalNote> createNote({required String ownerUserId}) async {
    final box = await _openBox();
    final id = const Uuid().v4();
    final note = LocalNote(
      id: id,
      userId: ownerUserId,
      content: [],
      sharedWith: [],
      lastModified: DateTime.now(),
    );
    await box.put(id, note);
    return note;
  }

  Future<LocalNote?> getNoteById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  Future<void> addParagraph({
    required String noteId,
    required String author,
    required String text,
  }) async {
    final box = await _openBox();
    final note = box.get(noteId);
    if (note != null) {
      note.content.add(LocalParagraph(
        author: author,
        text: text,
        timestamp: DateTime.now(),
      ));
      note.lastModified = DateTime.now();
      await note.save();
    }
  }


  @override
  Future<void> deleteNote({required String documentId}) async {
    final box = await _openBox();
    await box.delete(documentId);
  }

  @override
  Future<Iterable<LocalNote>> getAllNotes({required String ownerUserId}) async {
    final box = await _openBox();
    return box.values.where((n) => n.userId == ownerUserId);
  }

  @override
  Stream<Iterable<LocalNote>> allNotes({required String ownerUserId}) async* {
    final box = await _openBox();
    yield box.values.where((n) => n.userId == ownerUserId);
    // Hinweis: kein echter Stream, sondern einmalige Ausgabe
  }

  @override
  Future<void> updateNote({required String documentId, required String text}) async {
    // noch nicht genutzt → kannst du leer lassen oder richtig implementieren
    throw UnimplementedError('updateNote() ist lokal noch nicht implementiert');
  }
}
