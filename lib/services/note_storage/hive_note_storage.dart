import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../cloud/cloud_note.dart';
import '../local/local_note.dart';
import 'note_storage_interface.dart';

class HiveNoteStorage implements NoteStorage {
  static const String boxName = 'notes';

  Future<Box<LocalNote>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      Hive.registerAdapter(LocalNoteAdapter());
      await Hive.openBox<LocalNote>(boxName);
    }
    return Hive.box<LocalNote>(boxName);
  }

  @override
  Future<CloudNote> createNote({required String ownerUserId}) async {
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
    return CloudNote(
      documentId: note.id,
      ownerUserId: note.userId,
      content: [],
      sharedWith: [],
    );
  }

  @override
  Future<void> deleteNote({required String documentId}) async {
    final box = await _openBox();
    await box.delete(documentId);
  }

  @override
  Future<Iterable<CloudNote>> getAllNotes({required String ownerUserId}) async {
    final box = await _openBox();
    return box.values
        .where((n) => n.userId == ownerUserId)
        .map((n) => CloudNote(
              documentId: n.id,
              ownerUserId: n.userId,
              content: n.content.map((p) => NoteParagraph(
                author: p.author,
                text: p.text,
                timestamp: p.timestamp,
              )).toList(),
              sharedWith: n.sharedWith,
            ));
  }

  @override
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) async* {
    final box = await _openBox();
    yield box.values
        .where((n) => n.userId == ownerUserId)
        .map((n) => CloudNote(
              documentId: n.id,
              ownerUserId: n.userId,
              content: n.content.map((p) => NoteParagraph(
                author: p.author,
                text: p.text,
                timestamp: p.timestamp,
              )).toList(),
              sharedWith: n.sharedWith,
            ));
    // Hive unterstützt keine echten Datenbank-Streams → das ist ein einmaliger Snapshot
  }

  @override
  Future<void> updateNote({required String documentId, required String text}) async {
    throw UnimplementedError('updateNote() is not yet implemented');
    // final box = await _openBox();
    // final note = box.get(documentId);
    // if (note != null) {
    //   note.text = text;
    //   note.lastModified = DateTime.now();
    //   note.synced = false;
    //   await note.save();
    // }
  }
}
