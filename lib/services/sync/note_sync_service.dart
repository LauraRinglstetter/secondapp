import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';
import 'package:secondapp/services/remote/couchdb_api.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_paragraph.dart';


class NoteSyncService {
  final HiveNoteStorage _storage;
  final CouchDbApi _remote;

  NoteSyncService(this._storage, this._remote);

  Future<void> syncNotes() async {
    final unsynced = await _storage.getUnsyncedNotes();
    for (final note in unsynced) {
      final success = await _remote.uploadNote('notes', note);
      if (success) {
        await _storage.markAsSynced(note.id);
      } else {
        await _storage.markAsSyncFailed(note.id);
      }
    }
  }

    Future<void> fetchNotesFromCouchDb() async {
      final userId = _getUserId();
      final docs = await _remote.fetchNotes('notes', userId);

      for (final doc in docs) {
        final id = doc['_id'];
        final incomingParagraphs = (doc['content'] as List)
            .map((p) => LocalParagraph(
                  author: p['author'],
                  text: p['text'],
                  timestamp: DateTime.parse(p['timestamp']),
                ))
            .toList();

        final incomingNote = LocalNote(
          id: id,
          userId: doc['userId'],
          content: incomingParagraphs,
          sharedWith: List<String>.from(doc['sharedWith'] ?? []),
          lastModified: DateTime.parse(doc['lastModified']),
          synced: true,
        );

        final existingNote = await _storage.getNoteById(id);

        if (existingNote == null) {
          await _storage.saveNote(incomingNote);
          continue;
        }

        final combined = [...existingNote.content, ...incomingNote.content];
        final deduplicated = {
          for (final p in combined)
            '${p.author}-${p.text}-${p.timestamp.toIso8601String()}': p
        }.values.toList();

        deduplicated.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final mergedNote = existingNote.copyWith(
          content: deduplicated,
          sharedWith: incomingNote.sharedWith,
          lastModified: incomingNote.lastModified.isAfter(existingNote.lastModified)
              ? incomingNote.lastModified
              : existingNote.lastModified,
          synced: existingNote.synced && incomingNote.synced,
        );

        await _storage.saveNote(mergedNote);
      }

      final allLocalNotes = await _storage.getAllNotes(ownerUserId: userId);
      final fetchedIds = docs.map((doc) => doc['_id']).toSet();

      for (final note in allLocalNotes) {
        if (!fetchedIds.contains(note.id)) {
          await _storage.deleteNote(documentId: note.id);
        }
      }
    }

    String _getUserId() {
      return LocalSession.currentUser!.id;
    }
}