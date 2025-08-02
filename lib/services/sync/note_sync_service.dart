import 'dart:convert';
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
      print('🔄 Versuche, Notiz ${note.id} zu synchronisieren ...');

      final success = await _remote.uploadNote('notes', note);

      if (success) {
        await _storage.markAsSynced(note.id);
        print('✅ Erfolgreich synchronisiert: ${note.id}');
      } else {
        print('❌ Fehler beim Synchronisieren: ${note.id}');
      }
    }
  }

    Future<void> fetchNotesFromCouchDb() async {
      final userId = _getUserId();
      final docs = await _remote.fetchNotes('notes', userId);

      for (final doc in docs) {
        final id = doc['_id'];
        final alreadyExists = await _storage.getNoteById(id);
        if (alreadyExists != null) continue;

        final content = (doc['content'] as List)
            .map((p) => LocalParagraph(
                  author: p['author'],
                  text: p['text'],
                  timestamp: DateTime.parse(p['timestamp']),
                ))
            .toList();

        final note = LocalNote(
          id: id,
          userId: userId,
          content: content,
          sharedWith: List<String>.from(doc['sharedWith'] ?? []),
          lastModified: DateTime.parse(doc['lastModified']),
          synced: true,
        );

        await _storage.saveNote(note);
      }

      print('⬇️ Notizen aus CouchDB importiert: ${docs.length}');
    }

      String _getUserId() {
      // Hole den aktuell eingeloggten Benutzer
      // (du nutzt wahrscheinlich LocalSession)
      return LocalSession.currentUser!.id;
  }


}
