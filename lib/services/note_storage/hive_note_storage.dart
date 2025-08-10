import 'package:hive/hive.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:uuid/uuid.dart';
import '../local/local_note.dart';
import 'note_storage_interface.dart';

class HiveNoteStorage implements NoteStorage {
  static const String boxName = 'notes';

  Future<Box<LocalNote>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(LocalNoteAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(LocalParagraphAdapter());
      }// Wichtig!
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
      note.synced = false; 
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
    return box.values.where((n) =>
    n.userId == ownerUserId || n.sharedWith.contains(ownerUserId));
  }

  @override
  Stream<Iterable<LocalNote>> allNotes({required String ownerUserId}) async* {
    final box = await _openBox();
    yield box.values.where((n) => n.userId == ownerUserId);
    // Hinweis: kein echter Stream, sondern einmalige Ausgabe
  }

  Future<void> shareNoteWithUser({
    required String noteId,
    required String otherUserId,
  }) async {
    final box = await _openBox();
    final note = box.get(noteId);
    if (note != null && !note.sharedWith.contains(otherUserId)) {
      note.sharedWith.add(otherUserId);
      note.synced = false;
      await note.save();
    }
  }
  Future<void> markAsSyncFailed(String noteId) async {
  final box = await _openBox();
  final note = box.get(noteId);
  if (note != null) {
    note.synced = false; // bleibt unsynced
    await note.save();
  }
}



  @override
  Future<void> updateNote({required String documentId, required String text}) async {
    // noch nicht genutzt → kannst du leer lassen oder richtig implementieren
    throw UnimplementedError('updateNote() ist lokal noch nicht implementiert');
  }
  //Liste aller Notizen, die noch nicht synchronisiert wurden
  Future<List<LocalNote>> getUnsyncedNotes() async {
    final box = await _openBox();
    final currentUserId = LocalSession.currentUser?.id;

    if (currentUserId == null) return [];

    return box.values
        .where((note) =>
            note.synced == false &&
            (note.userId == currentUserId || note.sharedWith.contains(currentUserId)))
        .toList();
  }
  // Wenn Notiz erfolgreich synchronisiert wurde, dann als synchronisiert markiert
  Future<void> markAsSynced(String noteId) async {
    final box = await _openBox();
    final note = box.get(noteId);
    if (note != null) {
      note.synced = true;
      note.lastModified = DateTime.now();
      await note.save();
    }
  }

  Future<void> saveNote(LocalNote note) async {
    final box = await _openBox();
    await box.put(note.id, note);
  }



}
