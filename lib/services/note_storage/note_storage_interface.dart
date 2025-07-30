import '../cloud/cloud_note.dart';

abstract class NoteStorage {
  Future<CloudNote> createNote({required String ownerUserId});
  Future<void> deleteNote({required String documentId});
  Future<void> updateNote({required String documentId, required String text});
  Future<Iterable<CloudNote>> getAllNotes({required String ownerUserId});
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId});
}
