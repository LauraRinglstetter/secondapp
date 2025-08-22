import 'package:secondapp/services/local/local_note.dart';

abstract class NoteStorage {
  Future<LocalNote> createNote({required String ownerUserId});
  Future<void> deleteNote({required String documentId});
  Future<void> updateNote({required String documentId, required String text});
  Future<Iterable<LocalNote>> getAllNotes({required String ownerUserId});
  Stream<Iterable<LocalNote>> allNotes({required String ownerUserId});
}
